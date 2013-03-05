require 'puavo-ds/id_pool'
require 'puavo-ds/database_acl'
require 'tempfile'

class Database < ActiveLdap::Base
  ldap_mapping( :dn_attribute => "cn",
                :prefix => "",
                :classes => ['olcDatabaseConfig', 'olcHdbConfig', 'puavoDatabase'] )

  attr_accessor :samba_domain
  attr_accessor :kerberos_realm
#  before_save :set_attribute_values

  def initialize(args)
    ActiveLdap::Base.setup_connection( configurations["settings"]["ldap_server"].merge( "base" => "cn=config" ) )
    super

    set_attribute_values
  end

  def set_attribute_values
    self.olcDatabase = 'hdb'
    self.olcDbConfig = ['set_cachesize 0 10485760 0',
                        'set_lg_bsize 2097512',
                        'set_flags DB_LOG_AUTOREMOVE']
    self.olcDbCheckpoint = '64 5'
    self.olcDbCachesize = '10000'
    self.olcLastMod = 'TRUE'
    self.olcDbCheckpoint = '512 30'
    self.olcDbIndex = ['sambaSID pres,eq',
                       'sambaSIDList pres,eq',
                       'sambaGroupType pres,eq',
                       'member,memberUid pres,eq',
                       'puavoSchool pres,eq',
                       'puavoId pres,eq',
                       'puavoTag pres,eq',
                       'puavoDeviceType pres,eq',
                       'puavoHostname pres,eq,sub',
                       'displayName,puavoEduPersonReverseDisplayName pres,eq,sub',
                       'uid pres,eq',
                       'krbPrincipalName pres,eq',
                       'cn,sn,mail,givenName pres,eq,approx,sub',
                       'objectClass eq',
                       'entryUUID eq',
                       'entryCSN eq'
                       ]
    self.olcDbDirectory = "/var/lib/ldap/#{self.cn}"

    # Database ACLs
    suffix = self.olcSuffix
    samba_domain = self.samba_domain

    self.olcAccess = LdapAcl.generate_acls(suffix, samba_domain)
  end
end