FactoryGirl.define do
  factory :package, class: Package do
  end

  factory :package_abind, parent: :package do
    name 'abind'
    version '1.4-0'
    dependencies 'R (>= 1.5.0)'
    license 'LGPL (>= 2)'
  end

  factory :package_acceptance_sampling, parent: :package do
    name 'AcceptanceSampling'
    version '1.0-2'
    dependencies 'methods, R(>= 2.4.0), stats'
    license 'GPL (>= 3)'
  end

  factory :package_adabag, parent: :package do
    name 'adabag'
    version '3.1'
    dependencies 'rpart, mlbench, caret'
    license 'GPL (>= 2)'
  end

  factory :package_ACCLMA, parent: :package do
    name 'ACCLMA'
    version '1.0'
    license 'GPL-2'
  end
end
