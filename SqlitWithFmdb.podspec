
Pod::Spec.new do |s|

s.name         = "SqlitWithFmdb"
s.version      = "0.0.1"
s.summary      = "依赖Fmdb的简易操作"

s.homepage     = "https://github.com/zengxianshu/sqlit"

s.license      = "MIT"

s.author       = { "zengXianShu" => "zengxianshu0@163.com" }
s.platform     = :ios, "7.0"

s.source       = { :git => "https://github.com/zengxianshu/sqlit.git", :tag => s.version }

s.source_files  = "Pods/**/*"

s.public_header_files = ["Pods/fmdb/FMDB.h"]
#s.public_header_files = 'Pods/Classes/**/*.h'   #公开头文件地址
#s.dependency 'FMDB',
s.requires_arc = true

end
