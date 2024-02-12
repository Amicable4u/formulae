require 'fileutils'

class BodyslideAndOutfitStudio < Formula
  desc ""
  homepage ""
  url "https://github.com/ousnius/BodySlide-and-Outfit-Studio.git",
      tag:      "v5.6.3",
      revision: "b68a979c92db9759dca5bd7c8392517c5f14a008"
  version "5.6.3"
  sha256 "5a2a999979806b23a5e2ab9ff04cf60701f60489d13d3114f52f6b9d8ce81e64"
  license ""
  head "https://github.com/ousnius/BodySlide-and-Outfit-Studio.git", branch: "dev"

  # https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.4/wxWidgets-3.2.4.tar.bz2
  depends_on "wxwidgets" => ["3.2.4", :build]
  depends_on "cmake" => :build
  depends_on "glew" => :build

  resource "fbx" do
    url "https://www.autodesk.com/content/dam/autodesk/www/adn/fbx/2020-2-1/fbx202021_fbxsdk_clang_mac.pkg.tgz"
    sha256 "e6ea611a2d52107105680c9c57b6dbe99729fa95ef848539664f035d972bcb70"
  end

  def lin(filepath, text, lineno, *args, &block)
    tempfile=File.open(filepath + ".tmp", 'w')
    f=File.new(filepath)
    ln = 0
    f.each do |line|
      ln += 1
      tempfile<<line
      if ln==lineno
        tempfile << text + "\n"
      end
    end
    f.close
    tempfile.close
  
    FileUtils.mv(filepath + ".tmp", filepath)
  end

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    # Install FBX SDK
    resource("fbx").stage "."

    fbx_pkg = "fbx202021_fbxsdk_clang_macos.pkg"
    # Install the staged .pkg
    # TODO: may not need --expand, could just make the path longer
    system "pkgutil", "--expand-full", fbx_pkg, "fbx_pkg_contents"
    # system "pkgutil", "--expand-full", fbx_pkg_contents/"", "fbx_pkg_contents"

    buildpath.install Dir["fbx_pkg_contents/Root.pkg/Payload/Applications/Autodesk/FBX\ SDK"]
    # system("/usr/sbin/pkgutil", "--pkg-info-plist", fbx_pkg) 
    # system("/usr/sbin/pkgutil", "--files", fbx_pkg) 
    # system("/usr/sbin/pkgutil", "--install-from-file", fbx_pkg)

    # system("ln", "-s", "FBX\ SDK", "./FBX\ SDK")
    system("mv", "FBX\ SDK", "fbxsdk")

    # system "echo", "time to run ls"
    # system "ls", "-ltra"

    system "sed", "-i", "", "11s/.*/find_library(fbxsdk libfbxsdk.a PATHS ${fbxsdk_dir}\\/lib\\/clang\\/release\\/)/", "CMakeLists.txt"
    # system "sed", "-i", "'11i\'$'\n''message(PROJECT_SOURCE_DIR=\"${PROJECT_SOURCE_DIR}\")'", "CMakeLists.txt"
#     system "sed", "-i", "''", "'11i\\
# message(PROJECT_SOURCE_DIR=\"${PROJECT_SOURCE_DIR}\")\\
# '", "CMakeLists.txt"
    # system "sed", "-i", "''", "-e", "11s/^//p; 2s/^.*/text to insert/" file
    # sed -i '' '11i\
# message(PROJECT_SOURCE_DIR="${PROJECT_SOURCE_DIR}")' CMakeLists.txt
    # awk 'NR==2{print 1.5}1' CMakeLists.txt > tmp && mv tmp CMakeLists.txt

    # awk 'NR==11{print "message(PROJECT_SOURCE_DIR=\"${PROJECT_SOURCE_DIR}\")"}1' CMakeLists.txt > tmp
#     system "awk", "'NR==11{print \"message(PROJECT_SOURCE_DIR=\\\"${PROJECT_SOURCE_DIR}\\\")\"}1'", "CMakeLists.txt", ">", "tmp"
#     system "mv", "tmp", "CMakeLists.txt"

# system "function lin {
#   awk 'NR=='$2'{print \"'$1'\"}1' $3
# }"

# system "export", "txt=\"message(PROJECT_SOURCE_DIR=\\\"\${PROJECT_SOURCE_DIR}\\\")\""

# function lin {
#   awk 'NR=='$2'{print "'$1'"}1' $3
# }

    # text = "message(PROJECT_SOURCE_DIR=\\\"\\${PROJECT_SOURCE_DIR}\\\")"

    # system "lin", "#{text}", "11", "CMakelists.txt"
    
    lin("CMakeLists.txt", "message(PROJECT_SOURCE_DIR=\"${PROJECT_SOURCE_DIR}\")", 2)

    system "mkdir", "Release"
    cd "Release" do
      system "cmake", "-DCMAKE_BUILD_TYPE=Release", "-DCMAKE_CXX_FLAGS=\"-Wall\"", ".."
      system "make"
    end

    # raise "hell"
  end
end
