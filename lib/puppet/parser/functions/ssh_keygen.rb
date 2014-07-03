# Forked from https://github.com/fup/puppet-ssh @ 59684a8ae174
#
# Takes a Hash of config arguments:
#   Required parameters:
#     :name   (the name of the key - e.g 'my_ssh_key')
#     :request (what type of return value is requested (public, private, auth, known)
#
#   Optional parameters:
#     :type    (the key type - default: 'rsa')
#     :dir     (the subdir of /etc/puppet/ to store the key in - default: 'ssh')
#     :hostkey (weither the key should be a hostkey or not. defines weither to add it to known_hosts or not)
#     :hostaliases (specify aliases for the host for whom a hostkey is created (will be added to known_hosts))
#     :authkey (weither the key is an authkey or not. defines weither to add it to authorized_keys or not)
#     :as_hash (weither to return authorized_keys as list of hashes (only for request authorized keys))
#
require 'fileutils'

def init(fullpath)
    if File.exists?(fullpath) and not File.directory?(fullpath)
        raise Puppet::ParseError, "ssh_keygen(): #{fullpath} exists but is not directory"
    end
    if not File.directory?(fullpath)
        debug "creating directory #{fullpath}"
        FileUtils.mkdir_p fullpath
    end
end

def create_key_if_not_exists(fullpath, name, comment, type, hostkey, hostaliases, authkey, request)
    begin
        keyfile = "#{fullpath}/#{name}"
        unless File.exists?(keyfile)
            cmdline = "/usr/bin/ssh-keygen -q -t #{type} -N '' -C '#{comment}' -f #{keyfile}"
            output = %x[#{cmdline}]
            if $?.exitstatus != 0
                raise Puppet::ParseError, "calling '#{cmdline}' resulted in error: #{output}"
            end

           begin
                if authkey == true
                    add_key_to_authorized_keys(fullpath, name, keyfile)
                end
            rescue => e
                raise Puppet::ParseError, "ssh_keygen(): adding key to authorized_keys failed #{e}"
            end
        else
            debug "ssh_keygen: key already exists. using previously created key in given '#{request}' request"
        end
    rescue => e
        raise Puppet::ParseError, "ssh_keygen(): unable to generate ssh key (#{e})"
    end

    begin
        if hostkey == true
            add_key_to_known_hosts(fullpath, name, hostaliases, keyfile)
        end
    rescue => e
        raise Puppet::ParseError, "ssh_keygen(): adding key to known hosts failed #{e}"
    end
end

def add_key_to_known_hosts(fullpath, name, aliases, keyfile)
    debug "ssh_keygen: adding key #{name} to known_hosts file"

    known_hosts = "#{fullpath}/known_hosts"
    if not File.exists?(known_hosts)
        File.open(known_hosts, 'w') { |f| f.write "# managed by puppet\n" }
    end

    hostname  = lookupvar('hostname')
    fqdn      = lookupvar('fqdn')
    ipaddress = lookupvar('ipaddress')

    if not fqdn
        raise Puppet::ParseError, "unable to determine fqdn: please check system configuration"
    end

    hosts = "#{hostname},#{fqdn},#{ipaddress}"
    unless aliases.nil? or aliases == :undef
        hosts << "," << aliases
    end

    key             = get_pubkey(keyfile, false)
    search_string   = "^.* " + Regexp.escape(key) + "$"

    lines = File.open(known_hosts).readlines

    unless File.open(known_hosts).readlines.grep(/#{search_string}/).size > 0
        debug "key not found in known_hosts file, adding it."
        line = "#{hosts} #{key}"
        File.open(known_hosts, 'a') { |file| file.write(line) }
        debug "ssh_keygen: updated known_hosts file at '#{known_hosts}'"
    else
        debug "ssh_keygen: known_hosts file is already up to date."
    end
end

def add_key_to_authorized_keys(fullpath, name, keyfile)
    debug "ssh_keygen: adding key #{name} to authorized_keys file"

    authorized_keys = "#{fullpath}/authorized_keys"
    if not File.exists?(authorized_keys)
        File.open(authorized_keys, 'w') { |f| f.write "# managed by puppet\n" }
    end

    key       = get_pubkey(keyfile, false)

    line = "#{key}"
    File.open(authorized_keys, 'a') { |file| file.write(line) }

    debug "ssh_keygen: updated authorized_keys file at '#{authorized_keys}'"
end


def get_known_hosts(fullpath)
    known_hosts = "#{fullpath}/known_hosts"
    return File.open(known_hosts).read
end

def get_authorized_keys(fullpath, as_hash)
    known_hosts = "#{fullpath}/authorized_keys"

    debug "as_hash: xxx"
    unless as_hash == true
        return File.open(known_hosts).read
    end

    result = {}
    File.foreach(known_hosts) { |line|
        next if line =~ /^#/
        next if line =~ /^$/

        (type, key, comment) = line.split(' ')

        if comment.nil?
            debug "skipping invalid authorized_key line: '#{line}'"
        end

        result[comment] = { 
                'type'      => type,
                'key'       => key,
                'name'   => comment
        }
    }

    return result
end


def get_privkey(keyfile)
    begin
        kf = File.open(keyfile).read
        return kf
    rescue => e
        raise Puppet::ParseError, "ssh_keygen(): unable to read private key file: #{e}"
    end
end

def get_pubkey(keyfile, only_keypart = false)
    begin
        keyfile = "#{keyfile}.pub"
        pubkey = File.open(keyfile).read
        if only_keypart == true
            pubkey.scan(/^.* (.*) .*$/)[0][0]
        else
            return pubkey
        end 
    rescue => e
        raise Puppet::ParseError, "ssh_keygen: unable to read public key: #{key}"
    end
end


module Puppet::Parser::Functions
  newfunction(:ssh_keygen, :type => :rvalue) do |args|
    unless args.first.class == Hash then
      raise Puppet::ParseError, "ssh_keygen(): config argument must be a Hash"
    end

    config = args.first

    config = {
      'dir'                     => 'ssh',
      'type'                    => 'rsa',
      'hostkey'                 => false,
      'hostaliases'             => nil,
      'authkey'                 => false,
      'request'                 => nil,
      'comment'                 => nil,
      'as_hash'                 => false,
    }.merge(config)

    if config['request'].nil?
        raise Puppet::ParseError, "ssh_keygen(): request argument is required"
    end

    request = config['request']
    if config['name'].nil? and (request != 'authorized_keys' and request != 'known_hosts')
        raise Puppet::ParseError, "ssh_keygen(): name argument is required"
    end

    # Let comment default to something sensible, unless the user really
    # wants to set it to ''(then we don't stop him)
    if config['comment'].nil?
        hostname = lookupvar('hostname')
        if config['hostkey'] == true
            config['comment'] = hostname
        elsif config['authkey'] == true
            config['comment'] = "root@#{hostname}"
        end
    end


    # construct fullpath from puppet base and dir argument
    fullpath = "/etc/puppet/#{config['dir']}"

    init(fullpath)
    create_key_if_not_exists(
        fullpath,
        config['name'],
        config['comment'],
        config['type'],
        config['hostkey'],
        config['hostaliases'],
        config['authkey'],
        config['request']
    ) 

    # Check what mode of action is requested
    begin
        keyfile = "#{fullpath}/#{config['name']}"
        case config['request']
        when "public"
            return get_pubkey(keyfile)
        when "private"
            return get_privkey(keyfile)
        when "known_hosts"
            return get_known_hosts(fullpath)
        when "authorized_keys"
            # TODO: Add a flag for created keys, that they are auth keys
            # TODO: Add a method to create authorized_keys from auth flagged keys
            # TODO: Add a method to return authorized_keys content
            return get_authorized_keys(fullpath, config['as_hash'])
        end
    rescue => e
        raise Puppet::ParseError, "ssh_keygen(): unable to fulfill request '#{config['request']}': #{e}"
    end
  end
end
