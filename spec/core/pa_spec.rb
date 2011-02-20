#!/usr/bin/rspec
require "guten/core"
require "guten/core/pa"

require "fileutils"
require "tmpdir"

# init
$tmpdir = Dir.mktmpdir
Dir.chdir($tmpdir)

at_exit do
	FileUtils.rm_r $tmpdir
end

describe Pa do
	after(:all) do
		# empty $tmpdir
		FileUtils.rm_r Dir["*"]-%w(. ..)
	end

	describe "#glob" do
		before(:all) do 
			FileUtils.touch(%w(fa .fa))
		end

		context "call without any option" do
			it "returns 1 items" do
				Pa.glob("*").should have(1).items
			end
		end

		context "call with :dot option" do
			it "returns 2 items" do
				Pa.glob("*", :dot).should have(2).items
			end
		end
	end

	describe "#ls" do
		# fa .fa fa~ 
		# dira/
		#   dirb/
		#     b
		before(:all) do
			FileUtils.mkdir_p(["dira/dirb"])
			FileUtils.touch(%w(fa .fa fa~ dira/dirb/b))
		end

		it "ls() -> ls all" do
			Pa.ls().sort.sholud == %w(.fa dira fa fa~)
		end

		it "ls(:_dot) -> ls all except dot file" do
			Pa.ls(:_dot).sort.should == %w(dira fa fa~)
		end

		it "ls_r -> ls rescurive" do
		 	Pa.ls_r.sort.should == %w(.fa dira dira/dirb dira/dirb/b fa fa~)
		end


		it "ls(1) -> ls with option start=1" do
			Pa.ls(1) do |pa,i|
				i.shold == 1
				break
			end
		end

		it "ls{} -> ls with block" do
			Pa.ls{|pa| pa.fn if pa.fn=="fa"}.should == ["fa"]
		end

		it "ls(:nil){} -> ls with block with :nil option" do
			Pa.ls(:nil){|pa| pa.fn if pa.fn=="fa"}.gach(&:to_s).sort.should == ["","","","fa"]
		end

		it "ls([]){} -> ls with memo=[]" do
			Pa.ls([]){|pa,i,m| next if pa.fn=="fa"; m<<pa.fn; m }.sort.shold == %w(.fa dira fa~)
		end

	end

	describe "#mkdir" do
		it "mkdir" do
			Pa.mkdir("guten/tag")
			File.exists?("guten/tag").should be_true
			Fileutils.rm_("guten/tag")
		end
	end

	describe "#mv" do
		# a
		# dir/ b  
		# destdir/
		#   dir/ b  
		before :all do
			FileUtils.mkdir_p(%w(dir destdir/dir))
			FileUtils.touch(%w(a dir/b destdir/dir/b))
		end

		it "mv file - mv('a', 'b')" do
			Pa.mv("a", "b")
			File.exists?("a").should be_true
			File.exists?("b").should_not be_true
			Pa.mv("b", "a")
		end

		it "mv dir - mv('dir', 'dirc')" do
			Pa.mv("dir", "dirc")
			File.exists?("dirc").should be_true
			File.exists?("dir").should_not be_true
			Pa.mv("dirc", "dir")
		end

		it "mv dir to existing dir. - mv('dir', 'destdir')" do
			Pa.mv("dir", "destdir").should raise_error(Errno::EEXIST)
		end

		it "mv with option :overwire" do
			ino_a = File.lstat("dir/b").ino
			Pa.mv("dir", "destdir", :overwrite) 
			File.exists?("dir").should_not be_true
			File.lstat("destdir/dir/b").ino.should == ino_a
		end

	end

	describe "#cp" do
		# a symfile
		# dir/ b -- guten
		#   dira/
		# destdir/
		#   dir/ b -- tag
		before :all do
			FileUtils.mkdir_p(%w(dir/dira destdir/dir))
			FileUtils.touch(%w(a dir/b destdir/dir/b))
			File.symlink("a", "symfile")
			open("dir/b", "w"){|f|f.write "guten"}
			open("destdir/dir/b", "w"){|f|f.write "tag"}
		end

		it "cp file" do
			Pa.cp("a", "destdir")
			File.exists?("destdir/a").should be_true
		end

		it "cp directory" do
			Pa.cp("dir", "dirc")
			Dir.entries("dirc").should == Dir.entries("dir")
		end

		it "cp symlink" do
			Pa.cp("symfile", "symc")
			File.symlink?("symc").should be_true
		end

		it "cp symlink with :follink option" do
			Pa.cp("symfile", "symd", :follink)
			File.file?("symd").should be_true
		end

		it "cp src's full path layout -- cp(.., :parent)" do
			Pa.cp("a", "destdir", :parent)
			File.exists?( "./destdir"+Dir.getwd+"/a").should be_true
		end

		it "first remove dest dir, then cp -- cp(.., :rmdestdir)" do
			FileUtils.cp_r("destdir", "destdir_bak")

			Pa.cp("a", "destdir", :rmdestdir)
			File.file?("destdir").should be_true

			FileUtils.rm("destdir")
			FileUtils.mv("destdir_bak", "destdir")
		end

		it "cp(a,b) -- preserve mode,atime,mtime when cp" do
			Pa.chmod("a", 0777)
			Pa.cp("a", "stat")
			src_st = File.stat("a")
			dst_st = File.stat("stat")
			src_st.mode.should == dst_st.mode
			src_st.atime.should == dst_st.atime
			src_st.mtime.should == dst_st.mtime
		end

		it "cp(a,b,:backupdest) -- backup dest to dest~" do
			Pa.cp("a", "backup")
			Pa.cp("a", "backup", :backupdest)
			File.exists?("backup~").should_be true
		end

		it "cp(.., :overwrite) -- " do
			FileUtils.touch("file_overwrite")
			Pa.cp("a", "file_overwrite").should raise_error(Errno::EEXIST)
			Pa.cp("a", "file_overwrite", :overwrite).should_not raise_error(Errno::EEXIST)
		end

		it "cp name/ dir/name/ " do
			Pa.cp("dir", "destdir").should raise_error(Errno::EEXIST)
			Pa.cp("dir", "destdir", :overwrite)
			File.read("destdir/dir/b").should == "guten"
			File.directory?("destdir/dir/dira").should be_true
		end

		context ":update" do
			before :all do
				FileUtils.cp("a", "update")
			end

			it "==" do
				oldinode = File.stat("update").inode
				Pa.cp("a", "update", :update)
				File.lstat("update").inode.should == oldinode
			end

			it ">" do
				File.open("msg>","w"){|f|f.write("msg>")}
				Pa.cp("a", "update", :update)
				File.read("update").should == "msg>"
			end

			it "<" do
				File.open("msg>","w"){|f|f.write("msg<")}
				Pa.cp("a", "update", :update)
				File.read("update").should == "msg<"
			end

			it ":diff" do
				Pa.utime("update", nil, Time.now+60)
				Pa.cp("a", "update", :diff)
 				File.read("update").should == "msg>"
			end
		end
	end
end
