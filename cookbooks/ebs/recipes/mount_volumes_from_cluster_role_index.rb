log_cluster_volume_info('mount_volumes_from_cluster_role_index')

if cluster_ebs_volumes
  cluster_ebs_volumes.each do |conf|
    directory conf['mount_point'] do
      recursive true
      owner     conf['owner'] || 'root'
      group     conf['owner'] || 'root'
    end
    mount conf['mount_point'] do
      only_if{ File.exists?(conf['device']) }
      dev_type_str = `file -s '#{conf['device']}'`
      Chef::Log.info [dev_type_str].inspect
      case
      when conf['type']                                  then fstype conf['type']
      when dev_type_str =~ /SGI XFS filesystem data/     then fstype 'xfs'
      when dev_type_str =~ /Linux.*ext3 filesystem data/ then fstype 'ext3'
      else                                                    fstype 'ext3'
      end
      device    conf['device']
      options   conf['options'] || 'defaults'
      # To simply mount the volume: action[:mount]
      # To mount the volume and add it to fstab: action[:mount,:enable]. This
      #   can cause hellacious problems on reboot if the volume isn't attached.
      action    [:mount]
    end
  end
end
