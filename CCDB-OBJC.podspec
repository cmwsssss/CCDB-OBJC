Pod::Spec.new do |spec|

  spec.name         = "CCDB-OBJC"
  spec.version      = "1.0.0"
  spec.summary      = "CCDB is a database framwork built for Objc"

  spec.description  = <<-DESC
		     CCDB is a database framwork built for Objc
                   DESC

  spec.homepage     = "https://github.com/cmwsssss/CCDB-OBJC"

  spec.license      = "MIT"

  spec.author       = { "cmw" => "cmwsssss@hotmail.com" }

  spec.platform     = :ios, "6.0"

  spec.source       = { :git => "https://github.com/cmwsssss/CCDB-OBJC.git", :tag => "1.0.0" }

  spec.source_files  = "CCDB-OBJC", "CCDB-OBJC/**/*.{h,m}"
  spec.exclude_files = "CCDB-OBJC/Exclude"

end
