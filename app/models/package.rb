require 'net/http'

class Package < ActiveRecord::Base
  attr_accessible :name, :version, :dependencies, :suggestions, :license

  def self.download
    uri = URI('http://cran.r-project.org/src/contrib/PACKAGES.gz') 
    data = Net::HTTP.get(uri)

    File.open(Rails.root.join('tmp', 'PACKAGES.gz'), 'wb') do |f|
      f.write(data)
    end
  end

  def self.parse file_name 
    File.open(Rails.root.join(file_name)) do |f|
      gz = Zlib::GzipReader.new(f)

      package_attrs = {} 

      create_package = -> {
        unless package_attrs.empty?
          transformation_rules = {
            Package: :name, 
            Version: :version,
            Depends: :dependencies,
            Suggests: :suggestions,
            License: :license
          }

          transformed_package_attrs = transform_package_fields_name_to_db_fields_name(package_attrs, transformation_rules)
          
          Package.create transformed_package_attrs if Package.where(transformed_package_attrs.except(:dependencies, :suggestions, :license)).count == 0
        end
      }
      
      gz.each do |line|
        parsed_line = Dcf.parse(line).try(:first)

        if parsed_line
          if parsed_line.has_key? 'Package'
            create_package.call

            package_attrs = parsed_line
          else
            package_attrs.merge! parsed_line
          end
        end
      end

      create_package.call
    end
  end

  def self.transform_package_fields_name_to_db_fields_name package_attrs, transformation_rules
    # FIXME make all this names transformation in one line

    transformed_package_attrs = {}
 
    package_attrs.to_options.each do |key, value| 
      transformed_key = transformation_rules[key]
      transformed_package_attrs[transformed_key] = value if transformed_key
    end

    transformed_package_attrs
  end

  def self.download_path
    'tmp'
  end

  def get_additional_info
    `cd #{Rails.root.join(Package.download_path)}; tar xzf #{Rails.root.join(Package.download_path, "#{name}_#{version}.tar.gz")}; cd -`
  
    transformation_rules = {
      Title: :title,
      Author: :author,
      Maintainer: :maintainer
    }

    additional_attrs = {}

    File.open(Rails.root.join(Package.download_path, name, 'DESCRIPTION')) do |f|
      f.read.each_line do |line|
        parsed_line = Dcf.parse(line).try(:first)
        additional_attrs.merge! parsed_line if parsed_line
      end
    end

    `rm -rf #{Rails.root.join(Package.download_path, name)}`

    Package.transform_package_fields_name_to_db_fields_name additional_attrs, transformation_rules
  end

  def r_version_needed
    dependencies.match(/R\s{0,1}\((.*)\)/).try(:[], 1)
  end
end
