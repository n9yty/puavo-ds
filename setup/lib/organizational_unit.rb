class OrganizationalUnit < ActiveLdap::Base  
  ldap_mapping( :dn_attribute => "ou",
                :prefix => "dc=edu",
                :classes => ['top', 'organizationalUnit'] )

  def self.create_units
    ['People',
     'Groups',
     'Hosts',
     'Automount',
     'Roles',
     'Services',
     'System Accounts',
     'System Groups',
     'Password Policies',
     'Idmap',
     'Kerberos Realms'].each do |ou|
      OrganizationalUnit.create( "ou" => ou )
    end
      
    self.ldap_mapping( :dn_attribute => "ou",
                       :prefix => "ou=Hosts,dc=edu",
                       :classes => ['top', 'organizationalUnit'] )
    ['Servers',
     'Devices'].each do |ou|
      OrganizationalUnit.create( "ou" => ou )
    end
  end
end
