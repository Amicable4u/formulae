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
  
  resource "glext" do
    url "https://www.khronos.org/registry/OpenGL/api/GL/glext.h"
    sha256 "268476bdb8d537fb2a6cddab42c3f7ef558cca7f5ce743c855635bb3f2db9d64"
  end
  
  resource "khr" do
    url "https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h"
    sha256 "7b1e01aaa7ad8f6fc34b5c7bdf79ebf5189bb09e2c4d2e79fc5d350623d11e83"
  end

  resource "dx12" do
    url "https://github.com/microsoft/DirectX-Headers/archive/refs/tags/v1.611.0.tar.gz"
    sha256 "edb8b52b1379f841df5d0d5e11dde08e0c3912508179fb3711f163382e88865c"
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

    resource("khr").stage "#{prefix}/include"
    resource("glext").stage "#{prefix}/include"

    # Install FBX SDK
    resource("fbx").stage "."

    fbx_pkg = "fbx202021_fbxsdk_clang_macos.pkg"
    # Install the staged .pkg
    # TODO: may not need --expand, could just make the path longer
    system "pkgutil", "--expand-full", fbx_pkg, "fbx_pkg_contents"

    buildpath.install Dir["fbx_pkg_contents/Root.pkg/Payload/Applications/Autodesk/FBX\ SDK"]
    system("mv", "FBX\ SDK", "fbxsdk")

    # Fix FBX library paths
    system "sed", "-i", "", "10s/.*/set(fbxsdk_dir .\\/fbxsdk)/", "CMakeLists.txt"
    system "sed", "-i", "", "11s/.*/find_library(fbxsdk fbxsdk PATHS ${fbxsdk_dir}\\/2020.2.1\\/lib\\/clang\\/release)/", "CMakeLists.txt"
    
    # Enable cmake debug mode
    lin("CMakeLists.txt", "set(CMAKE_FIND_DEBUG_MODE TRUE)", 2)
    lin("CMakeLists.txt", "set(CMAKE_VERBOSE_MAKEFILE on)", 3)

    # Fix GLEW library paths
    lin("CMakeLists.txt", "set(GLEW_LIBRARIES #{Formula["glew"].opt_lib}/libGLEW.dylib)", 13)
    lin("CMakeLists.txt", "set(GLEW_INCLUDE_DIRS #{Formula["glew"].opt_include})", 14)
    
    # include DirectX 12 headers
    resource("dx12").stage "./lib/dx12"
    lin("CMakeLists.txt", "\tlib/dx12/include/wsl", 109)
    lin("CMakeLists.txt", "\tlib/dx12/include/directx", 109)
    lin("CMakeLists.txt", "\tlib/dx12/include/wsl/stubs", 109)
    lin("CMakeLists.txt", "\tlib/dx12/include/wsl", 115)
    lin("CMakeLists.txt", "\tlib/dx12/include/directx", 115)
    lin("CMakeLists.txt", "\tlib/dx12/include/wsl/stubs", 115)
    lin("lib/FSEngine/FSBSA.cpp", "#include <basetsd.h>", 42)

    system "mkdir", "Release"
    cd "Release" do
      system "cmake", "-DCMAKE_BUILD_TYPE=Release", "-DCMAKE_CXX_FLAGS=\"-Wall\"", "-DGLEW_DIR=#{Formula["glew"].opt_lib}", "-DGLEW_LIBRARY=#{Formula["glew"].opt_lib}/libGLEW.dylib", ".."
      system "make"
    end

    # raise "hell"
  end
end
