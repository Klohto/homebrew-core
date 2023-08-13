require "language/node"
class TerraformRover < Formula
  desc "Terraform Visualizer"
  homepage "https://github.com/im2nguyen/rover"
  url "https://github.com/im2nguyen/rover/archive/refs/tags/v0.3.3.tar.gz"
  sha256 "491709df11c70c9756e55f4cd203321bf1c6b92793b8db91073012a1f13b42e5"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "968e2719282cd29685415ea7e18963d0c4ee9faf08c9d506cb3a15b69d6fb164"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a91f264c414c45431d9f49775405e736d8c98fdad348d2890189491eeaf14509"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "2585975e144bff4b942e06fea9b4a537845506d8753c83cdd0604242f25565cd"
    sha256 cellar: :any_skip_relocation, ventura:        "06ed2350c1cfb7e24b9a00d414e8bbce8c6f3ed5cc62fc7c01de2dedadd10b18"
    sha256 cellar: :any_skip_relocation, monterey:       "2fb8acc2af0c3029d217e0143115e34fd9ceca18cb6372053f35fa19a5d1fe15"
    sha256 cellar: :any_skip_relocation, big_sur:        "bbb836ca74b099587811edbe6806cd87767c543417f4bbc7043ee55fb00a9d3e"
    sha256 cellar: :any_skip_relocation, catalina:       "cb3ea8a62a309585e40a3ebca0f8633de15d80acfaed963046591d4ad1d610bf"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "7352915d9f3322d4795ee475095c00c2cc6c3f206501f00194b9a9f251add4c9"
  end

  depends_on "go" => :build
  depends_on "node"
  depends_on "terraform"

  # build patch for building with node 20 and go 1.21.0
  # fix `Error: error:0308010C:digital envelope routines::unsupported` error
  # upstream patch PR, https://github.com/im2nguyen/rover/pull/128
  patch do
    url "https://github.com/im2nguyen/rover/commit/8f5c9ca2ca6294c6a0463199ace822335c780041.patch?full_index=1"
    sha256 "c13464fe2de234ab670e58cd9f8999d23b088260927797708ce00bd5a11ce821"
  end
  patch do
    url "https://github.com/im2nguyen/rover/commit/989802276f74c57406a6b23a8d7ccc470fcdc975.patch?full_index=1"
    sha256 "3550755a11358385000f1a6af96a305c3f49690949d079d8e4fd59b8d17a06f5"
  end

  def install
    Language::Node.setup_npm_environment
    cd "ui" do
      system "npm", "install", *Language::Node.local_npm_install_args
      system "npm", "run", "build"
    end
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    (testpath/"main.tf").write <<~EOS
      output "hello_world" {
        value = "Hello, World!"
      }
    EOS
    system bin/"terraform-rover", "-standalone", "-tfPath", Formula["terraform"].bin/"terraform"
    assert_predicate testpath/"rover.zip", :exist?

    assert_match version.to_s, shell_output("#{bin}/terraform-rover --version")
  end
end
