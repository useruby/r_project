require 'net/http'

class Package < ActiveRecord::Base
  attr_accessible :name, :version, :dependencies, :r_version_needed, :suggestions, :license

  def self.download
    uri = URI('http://cran.r-project.org/src/contrib/PACKAGES.gz') 
    data = Net::HTTP.get(uri)

    File.open(Rails.root.join('tmp', 'PACKAGES.gz'), 'wb') do |f|
      f.write(data)
    end
  end

  def self.parse file_name
    File.open(Rails.root.join('tmp', 'PACKAGES.gz')) do |f|
      gz = Zlib::GzipReader.new(f)

      package_attrs = {} 
      
      gz.each do |line|
        parsed_line = Dcf.parse(line).try(:first)

        if parsed_line
          if parsed_line.has_key? 'Package'
            Package.create transform_package_fields_name_to_db_fields_name(package_attrs) unless package_attrs.empty?

            package_attrs = parsed_line
          else
            package_attrs.merge! parsed_line
          end
        end
      end
    end
  end

  def self.transform_package_fields_name_to_db_fields_name package_attrs
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
end
