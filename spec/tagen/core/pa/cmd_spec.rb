require "spec_helper"
require "fileutils"
require "tmpdir"

describe Pa do
	before :all do
		$tmpdir = Dir.mktmpdir
		Dir.chdir($tmpdir)
	end

	after(:all) do
		FileUtils.rm_r $tmpdir
	end

	describe "#_rmdir" do
		# dir/
		#   a
		#  dira/
		#    aa
		before(:all) do	
			@_rmdir = Pa.method(:_rmdir)
			FileUtils.mkdir_p(%w(dir/dira))
			FileUtils.touch(%w(dir/a dir/dira/aa))
		end

		it "remove directory" do
			@_rmdir.call Pa("dir")
			File.exists?("dir").should be_false
		end
	end

	# rm family
	describe "" do
		# a
		# dir/ 
		#   dira/
		#   a 
		before :each do
			FileUtils.mkdir_p(%w(dir/dira))
			FileUtils.touch(%w(a dir/a))
		end

		describe "#rm" do
			it "remove file" do
				Pa.rm "a"
				File.exists?("a").should be_false
				lambda{Pa.rm("dir")}.should raise_error(Errno::EISDIR)
			end
		end

		describe "#rmdir" do
			it "remove directory" do
				Pa.rmdir "dir"
				File.exists?("dir").should be_false
				lambda{Pa.rmdir("a")}.should raise_error(Errno::ENOTDIR)
			end
		end

		describe "#rm_r" do
			it "remove both file and directory" do
				Pa.rm "a"
				File.exists?("a").should be_false
				Pa.rm_r "dir"
				File.exists?("dir").should be_false
			end
		end

		describe "#rm_if" do
			it "remove if condition" do
				Pa.rm_if "." do |pa|
					next if pa.p=="a"
					yield if pa.b=="a"
				end

			File.exists?("a").should be_true 
			File.exists?("dir/dira/a").should be_false
		end
	end

	end

	describe "#mkdir" do
		after :each do
			FileUtils.rm_r Dir["*"]-%w(. ..)
		end

		it "mkdir" do
			Pa.mkdir("guten/tag")
			File.exists?("guten/tag").should be_true
		end
	end


	describe "#_copy" do
		# a symfile
		# ab
		# ac
		# dir/ 
		#   b   # guten
		#   dira/
		#     c
		# destdir/
		#   b  # tag
		#   dir/ 
		before :all do
			@_copy = Pa.method(:_copy)
			FileUtils.mkdir_p(%w(dir/dira destdir/dir))
			FileUtils.touch(%w(a ab ac dir/b dir/dira/c destdir/dir/b))
			File.symlink("a", "symfile")
			open("dir/b", "w"){|f|f.write "guten"}
			open("destdir/dir/b", "w"){|f|f.write "tag"}
		end

		it "_copy file" do
			@_copy.call Pa('a'), Pa('b')
			File.exists?('b').should be_true
		end

		it "_copy directory" do
			@_copy.call Pa('dir'), Pa('dirc')
			Dir.entries('dirc').should == Dir.entries('dir')
		end

		context "with :symlink" do

			it "_copy" do
				@_copy.call Pa('symfile'), Pa('symfilea')
				File.symlink?('symfilea').should be_true
			end

			it "_copy with :folsymlink" do
				@_copy.call Pa('symfile'), Pa('folsymlink'), folsymlink:true
				File.symlink?('folsymlink').should be_false
				File.file?('folsymlink').should be_true
			end

		end

		context "with :mkdir" do
			it "_copy" do
				lambda{Pa.cp "a", "destdir/mkdir/dir"}.should raise_error(Errno::ENOENT)
			end

			it "_copy with :mkdir" do
				lambda{Pa.cp "a", "destdir/mkdir/dir", mkdir:true}.should_not raise_error(Errno::ENOENT)
				File.exists?("destdir/mkdir/dir/a").should be_true
			end

			it "_copy with :mkdir" do
				lambda{Pa.cp "a", "destdir/mkdira", mkdir:true}.should_not raise_error(Errno::ENOENT)
				File.exists?("destdir/mkdira/a").should be_true
			end
		end

		context "with :overwrite" do
			it "_copy" do
				File.open("destdir/overwrite","w"){|f|f.write("")}
				lambda{Pa.cp "a", "destdir/overwrite"}.should raise_error(Errno::EEXIST)
			end

			it "_copy with :overwrite" do
				lambda{Pa.cp "a", "destdir/overwrite", overwrite:true}.should_not raise_error(Errno::EEXIST)
			end
		end

	end

	describe "#cp" do
		it "cp file destdir/file" do
			Pa.cp "a", "destdir/aa" 
			File.exists?("destdir/aa").should be_true
		end

		it "cp file destdir/" do
			Pa.cp "a", "destdir"
			File.exists?("destdir/a").should be_true
		end

		it "cp file1 file2 .. dest_file" do
			lambda{Pa.cp(%w(a ab), "ac")}.should raise_error(Errno::ENOTDIR)
		end

		it "cp file1 file2 .. dird/" do
			Dir.mkdir 'dird'
			Pa.cp %w(a ab), "dird"
			File.exists?("dird/a").should be_true
			File.exists?("dird/ab").should be_true
		end
	end

	describe "#_move" do
		# a
		# dir/ b  
		before :each do
			@_move = Pa.method(:_move)
			FileUtils.mkdir_p(%w(dir))
			FileUtils.touch(%w(a dir/b))
		end
		after :each do
			FileUtils.rm_r Dir["*"]-%w(. ..)
		end

		it "mv a dir/a" do
			ino = File.stat('a').ino
			@_move.call Pa("a"), Pa("dir/a"), {}
			File.stat('dir/a').ino.should == ino
			File.exists?("a").should be_false
		end
		
		context "with :overwrite" do
			it "mv a dir/b" do
				lambda{@_move.call Pa("a"), Pa("dir/b"), {}}.should raise_error Errno::EEXIST
			end

			it "mv a dir/b :overwrite" do
				ino = File.stat('a').ino
				@_move.call Pa("a"), Pa("dir/b"), overwrite:true
				File.stat("dir/b").ino.should == ino
			end
		end
	end

	describe "#mv" do
		# a b c
		# dir/ aa  
		before :each do
			@_move = Pa.method(:_move)
			FileUtils.mkdir_p(%w(dir))
			FileUtils.touch(%w(a b c dir/aa))
		end
		after :each do
			FileUtils.rm_r Dir["*"]-%w(. ..)
		end

		it "mv a dir/" do
			Pa.mv "a", "dir"
			File.exists?("dir/a").should be_true
		end

		it "mv a b .. file" do
			lambda{Pa.mv(%w(a b), "c")}.should raise_error(Errno::ENOTDIR)
		end

		it "mv file1 file2 .. dir/" do
			Pa.mv %w(a b), "dir"
			File.exists?("dir/a").should be_true
			File.exists?("dir/b").should be_true
		end
	end

end