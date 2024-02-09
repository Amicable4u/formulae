# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
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

  resource "fbx" do
    url "https://www.autodesk.com/content/dam/autodesk/www/adn/fbx/2020-2-1/fbx202021_fbxsdk_clang_mac.pkg.tgz"
    sha256 "e6ea611a2d52107105680c9c57b6dbe99729fa95ef848539664f035d972bcb70"
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

    # system("ln", "-s", "/Applications/Autodesk/FBX\ SDK", "./FBX\ SDK")

    system "echo", "time to run ls"
    system "ls", "-ltra"

    raise "hell"
    # system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    # system "cmake", "--build", "build"
    # system "cmake", "--install", "build"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # verify the functionality of the software.
    # Run the test with `brew test BodySlide-and-Outfit-Studio`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
