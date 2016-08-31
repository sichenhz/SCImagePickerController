Pod::Spec.new do |s|
  s.name         = "SCImagePickerController"
  s.version      = "1.0.1"
  s.summary      = "A photo album"
  s.homepage     = "https://github.com/SeJasonWang/SCImagePickerController"
  s.license      = "MIT"
  s.author       = { "wangsichen" => "jasonwong@hzclever.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/SeJasonWang/SCImagePickerController.git", :tag => "1.0.1" }
  s.source_files  = 'SCImagePickerController/SCImagePickerController/*.{h,m}'
  s.resource_bundles = {
    'SCImagePickerController' => ['SCImagePickerController/SCImagePickerController.bundle/*.png']
  }
  s.requires_arc = true

end
