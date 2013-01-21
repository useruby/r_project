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
          transformed_package_attrs = transform_package_fields_name_to_db_fields_name(package_attrs)
          
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

  def self.transform_package_fields_name_to_db_fields_name package_attrs
    # FIXME move all this code to create_package proc
    # FIXME make all this names transformation in one line

    transformed_package_attrs = {}

    names_transformation = {
      Package: :name, 
      Version: :version,
      Depends: :dependencies,
      Suggests: :suggestions,
      License: :license
    }

    package_attrs.to_options.each do |key, value| 
      transformed_key = names_transformation[key]
      transformed_package_attrs[transformed_key] = value if transformed_key
    end

    transformed_package_attrs
  end

  def r_version_needed
    dependencies.match(/R\s{0,1}\((.*)\)/).try(:[], 1)
  end
end
