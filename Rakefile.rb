require "rubygems"
require "bundler"
Bundler.setup
$: << './'

require 'albacore'
require 'rake/clean'
require 'semver'

require 'buildscripts/utils'
require 'buildscripts/paths'
require 'buildscripts/project_details'
require 'buildscripts/environment'

# to get the current version of the project, type 'SemVer.find.to_s' in this rake file.

desc 'generate the shared assembly info'
assemblyinfo :assemblyinfo => ["env:release"] do |asm|
  data = commit_data() #hash + date
  asm.product_name = PROJECTS[:bzip][:title]
  #asm.description = PROJECTS[:bzip][:description] + " #{data[0]} - #{data[1]}"
  asm.company_name = PROJECTS[:bzip][:company]
  # This is the version number used by framework during build and at runtime to locate, link and load the assemblies. When you add reference to any assembly in your project, it is this version number which gets embedded.
  asm.version = BUILD_VERSION
  # Assembly File Version : This is the version number given to file as in file system. It is displayed by Windows Explorer. Its never used by .NET framework or runtime for referencing.
  asm.file_version = BUILD_VERSION
  asm.custom_attributes :AssemblyInformationalVersion => "#{BUILD_VERSION}" # disposed as product version in explorer
    #:CLSCompliantAttribute => false,
    #:AssemblyConfiguration => "#{CONFIGURATION}",
    #:Guid => PROJECTS[:bzip][:guid]
  #asm.com_visible = false
  asm.copyright = PROJECTS[:bzip][:copyright]
  asm.output_file = File.join(FOLDERS[:src], 'SolutionInfo.cs')
  asm.namespaces = "System", "System.Reflection", "System.Runtime.InteropServices", "System.Security"
end


desc "build sln file"
msbuild :msbuild do |msb|
  msb.solution   = FILES[:sln]
  msb.properties :Configuration => CONFIGURATION
  msb.targets    :Clean, :Build
end


task :bzip_output => [:msbuild] do
  target = File.join(FOLDERS[:binaries], PROJECTS[:bzip][:id])
  copy_files FOLDERS[:bzip][:out], "*.{xml,dll,pdb,config}", target
  CLEAN.include(target)
end


task :zip_output => [:msbuild] do
  target = File.join(FOLDERS[:binaries], PROJECTS[:zip][:id])
  copy_files FOLDERS[:zip][:out], "*.{xml,dll,pdb,config}", target
  CLEAN.include(target)
end


task :zipred_output => [:msbuild] do
  target = File.join(FOLDERS[:binaries], PROJECTS[:zipred][:id])
  copy_files FOLDERS[:zipred][:out], "*.{xml,dll,pdb,config}", target
  CLEAN.include(target)
end


task :zlib_output => [:msbuild] do
  target = File.join(FOLDERS[:binaries], PROJECTS[:zlib][:id])
  copy_files FOLDERS[:zlib][:out], "*.{xml,dll,pdb,config}", target
  CLEAN.include(target)
end

task :output => [:bzip_output, :zip_output, :zipred_output, :zlib_output]
task :nuspecs => [:bzip_nuspec, :zip_nuspec, :zlib_nuspec]

desc "Create a nuspec for 'BZip2'"
nuspec :bzip_nuspec do |nuspec|
  nuspec.id = "#{PROJECTS[:bzip][:nuget_key]}"
  nuspec.version = BUILD_VERSION
  nuspec.authors = "#{PROJECTS[:bzip][:authors]}"
  nuspec.description = "#{PROJECTS[:bzip][:description]}"
  nuspec.title = "#{PROJECTS[:bzip][:title]}"
  # nuspec.projectUrl = 'http://github.com/haf' # TODO: Set this for nuget generation
  nuspec.language = "en-US"
  nuspec.licenseUrl = "http://www.apache.org/licenses/LICENSE-2.0" # TODO: set this for nuget generation
  nuspec.requireLicenseAcceptance = "false"
  
  nuspec.output_file = FILES[:bzip][:nuspec]
  nuspec_copy(:bzip, "Ionic.#{PROJECTS[:bzip][:id]}.{dll,pdb,xml}")
end


desc "Create a nuspec for 'Zip'"
nuspec :zip_nuspec do |nuspec|
  nuspec.id = "#{PROJECTS[:zip][:nuget_key]}"
  nuspec.version = BUILD_VERSION
  nuspec.authors = "#{PROJECTS[:zip][:authors]}"
  nuspec.description = "#{PROJECTS[:zip][:description]}"
  nuspec.title = "#{PROJECTS[:zip][:title]}"
  # nuspec.projectUrl = 'http://github.com/haf' # TODO: Set this for nuget generation
  nuspec.language = "en-US"
  nuspec.licenseUrl = "http://www.apache.org/licenses/LICENSE-2.0" # TODO: set this for nuget generation
  nuspec.requireLicenseAcceptance = "false"
  
  nuspec.output_file = FILES[:zip][:nuspec]
  nuspec_copy(:zip, "Ionic.#{PROJECTS[:zip][:id]}.{dll,pdb,xml}")
end

desc "Create a nuspec for 'Zlib'"
nuspec :zlib_nuspec do |nuspec|
  nuspec.id = "#{PROJECTS[:zlib][:nuget_key]}"
  nuspec.version = BUILD_VERSION
  nuspec.authors = "#{PROJECTS[:zlib][:authors]}"
  nuspec.description = "#{PROJECTS[:zlib][:description]}"
  nuspec.title = "#{PROJECTS[:zlib][:title]}"
  # nuspec.projectUrl = 'http://github.com/haf' # TODO: Set this for nuget generation
  nuspec.language = "en-US"
  nuspec.licenseUrl = "http://www.apache.org/licenses/LICENSE-2.0" # TODO: set this for nuget generation
  nuspec.requireLicenseAcceptance = "false"
  
  nuspec.output_file = FILES[:zlib][:nuspec]
  nuspec_copy(:zlib, "Ionic.#{PROJECTS[:zlib][:id]}.{dll,pdb,xml}")
end

task :nugets => [:"env:release", :nuspecs, :bzip_nuget, :zip_nuget, :zlib_nuget]

desc "nuget pack 'BZip2'"
nugetpack :bzip_nuget do |nuget|
   nuget.command     = "#{COMMANDS[:nuget]}"
   nuget.nuspec      = "#{FILES[:bzip][:nuspec]}"
   # nuget.base_folder = "."
   nuget.output      = "#{FOLDERS[:nuget]}"
end


desc "nuget pack 'Zip'"
nugetpack :zip_nuget do |nuget|
   nuget.command     = "#{COMMANDS[:nuget]}"
   nuget.nuspec      = "#{FILES[:zip][:nuspec]}"
   # nuget.base_folder = "."
   nuget.output      = "#{FOLDERS[:nuget]}"
end


desc "nuget pack 'Zlib'"
nugetpack :zlib_nuget do |nuget|
   nuget.command     = "#{COMMANDS[:nuget]}"
   nuget.nuspec      = "#{FILES[:zlib][:nuspec]}"
   # nuget.base_folder = "."
   nuget.output      = "#{FOLDERS[:nuget]}"
end

task :publish => [:"env:release", :bzip_nuget_push, :zip_nuget_push, :zlib_nuget_push]

desc "publishes (pushes) the nuget package 'BZip2'"
nugetpush :bzip_nuget_push do |nuget|
  nuget.command = "#{COMMANDS[:nuget]}"
  nuget.package = "#{File.join(FOLDERS[:nuget], PROJECTS[:bzip][:nuget_key] + "." + BUILD_VERSION + '.nupkg')}"
# nuget.apikey = "...."
  nuget.source = URIS[:nuget_offical]
  nuget.create_only = false
end


desc "publishes (pushes) the nuget package 'Zip'"
nugetpush :zip_nuget_push do |nuget|
  nuget.command = "#{COMMANDS[:nuget]}"
  nuget.package = "#{File.join(FOLDERS[:nuget], PROJECTS[:zip][:nuget_key] + "." + BUILD_VERSION + '.nupkg')}"
# nuget.apikey = "...."
  nuget.source = URIS[:nuget_offical]
  nuget.create_only = false
end


desc "publishes (pushes) the nuget package 'Zlib'"
nugetpush :zlib_nuget_push do |nuget|
  nuget.command = "#{COMMANDS[:nuget]}"
  nuget.package = "#{File.join(FOLDERS[:nuget], PROJECTS[:zlib][:nuget_key] + "." + BUILD_VERSION + '.nupkg')}"
# nuget.apikey = "...."
  nuget.source = URIS[:nuget_offical]
  nuget.create_only = false
end

task :default  => ["env:net35", "env:release", "assemblyinfo", "msbuild", "output", "nugets"]