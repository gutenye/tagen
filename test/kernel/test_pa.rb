#!/usr/bin/env ruby
require "minitest/unit"
require "fileutils"
require_relative "../../kernel/pa"
require_relative "../../kernel"
MiniTest::Unit.autorun

# startup
proc do
	tmppa = File.dirname(__FILE__)+"/testdata_pa"
	#begin FileUtils.rm_r(tmppa) rescue Errno::ENOTENT end
	begin Dir.mkdir(tmppa) rescue Errno::EEXIST end
	Dir.chdir(tmppa)
end.call

class Test_1 < MiniTest::Unit::TestCase

	def init(&blk) #{{{1
		dirs  = ["dir1a" , "dir1b" , ".dir1c" , "dir1a/dir2a" , "dir1a/dir2a/dir3a"]
		files = ["file1a", "file1b", ".file1c", "dir1a/file2a", "dir1a/dir2a/file3a"] 
		@file_nrs = 7
		@all_nrs = 11

		FileUtils.mkdir_p(dirs)
		FileUtils.touch(files)

		#files.gach {|p| File.open(p, "w"){|f| f.write("")} } # ms bug f.write("")
		File.symlink("file1a", "sym1a") if !win32?
		File.open("file1a", "w"){|f| f.write("guten")}
		File.open("file1b", "w"){|f| f.write("tag")}

		begin
			blk.call
		ensure
			FileUtils.rm_r Dir.glob("*")
		end
	end # def init

	# makesure rm * after blk
	def cleanup &blk
		begin
			blk.call
		ensure
			Dir.foreach(".") do |fname|
				next if %w(. ..).include? fname
				FileUtils.rm_r fname
			end
		end
	end

	def test_1
		#p Pa.join("","a")
	end


	def test_glob 
		# fa .fa 
		FileUtils.touch(%w(fa .fa))

		cleanup do
			assert_equal 1, Pa.glob("*").size
			assert_equal 2, Pa.glob("*", :dot).size
		end
	end # def test_glob

	# dir traverse 
	def test_ls
		# fa .fa fa~ 
		# dira/
		#   dirb/
		#     b
		FileUtils.mkdir_p(["dira/dirb"])
		FileUtils.touch(%w(fa .fa fa~ dira/dirb/b))

		cleanup do
			assert_equal %w(.fa dira fa fa~), Pa.ls.sort
			assert_equal %w(dira fa fa~), Pa.ls(:_dot).sort
			assert_equal %w(.fa dira fa), Pa.ls(:_bak).sort
			assert_equal %w(.fa dira dira/dirb dira/dirb/b fa fa~), Pa.ls_r.sort

			# start=1
			Pa.ls(1){|pa,i| assert_equal 1, i; break }

			# :nil
			assert_equal ["fa"], Pa.ls{|pa| pa.fn if pa.fn=="fa"}
			assert_equal ["","","","fa"], Pa.ls(:nil){|pa| pa.fn if pa.fn=="fa"}.gach(&:to_s).sort

			# memo=[]
			assert_equal %w(.fa dira fa~), Pa.ls([]){|pa,i,m| next if pa.fn=="fa"; m<<pa.fn; m }.sort

		end # cleanup
	end # def test_dir

	def test_mkdir #{{{1
		cleanup do
			Pa.mkdir("guten/tag")
			assert File.exists?("guten/tag")
		end
	end
			
	def test_rm  
		# a
		# dir/a
		FileUtils.mkdir("dir")
		FileUtils.touch(%w(a dir/a))

		cleanup do
			Pa.rm("*")
			assert_equal 1+2, Dir.entries(".").size # include . ..

			Pa.rm_r("*")
			assert_equal 0+2, Dir.entries(".").size
		end
	end # test_rm

	def mktmpdir(&blk)
		Pa.mkdir("tmp")
		begin
			blk.call
		ensure
			Pa.rmdir("tmp")
		end
	end

	def test_mv #{{{1
		# a
		# dir/ b  
		# destdir/
		#   dir/ b  
		FileUtils.mkdir_p(%w(dir destdir/dir))
		FileUtils.touch(%w(a dir/b destdir/dir/b))

		cleanup do
			Pa.mv("a", "b")
			refute File.exists?("a")
			assert File.exists?("b")
			Pa.mv("b", "a")

			Pa.mv("dir", "dirc")
			refute File.exists?("dir")
			assert File.exists?("dirc")
			Pa.mv("dirc", "dir")

			# :overwrite
			assert_raises Errno::EEXIST do Pa.mv("dir", "destdir") end
			ino_a = File.lstat("dir/b").ino
			Pa.mv("dir", "destdir", :overwrite) 
			refute File.exists?("dir")
			assert_equal ino_a, File.lstat("destdir/dir/b").ino 
		end
	end # test_mv

	def test_cp #{{{1
		# a symfile
		# dir/ b -- guten
		#   dira/
		# destdir/
		#   dir/ b -- tag
		FileUtils.mkdir_p(%w(dir/dira destdir/dir))
		FileUtils.touch(%w(a dir/b destdir/dir/b))
		File.symlink("a", "symfile")
		open("dir/b", "w"){|f|f.write "guten"}
		open("destdir/dir/b", "w"){|f|f.write "tag"}

		cleanup do
			# cp normal file
			Pa.cp("a", "destdir")
			assert File.exists?("destdir/a")

			# cp directory
			Pa.cp("dir", "dirc")
			assert_equal Dir.entries("dir"), Dir.entries("dirc")

			# cp symlink
			Pa.cp("symfile", "symc")
			assert File.symlink?("symc")
			Pa.cp("symfile", "symd", :follink)
			assert File.file?("symd")

			# :parent
			if not win32?
				Pa.cp("a", "destdir", :parent)
				assert File.exists?( "./destdir"+Dir.getwd+"/a")
			end

			# :rmdestdir 
			FileUtils.cp_r("destdir", "destdir_bak")
			Pa.cp("a", "destdir", :rmdestdir)
			assert File.file?("destdir")
			# cleanup
			FileUtils.rm("destdir")
			FileUtils.mv("destdir_bak", "destdir")

			# mode atime mtime
			Pa.chmod("a", 0777)
			Pa.cp("a", "stat")
			src_st = File.stat("a")
			dst_st = File.stat("stat")
			assert_equal src_st.mode, dst_st.mode
			assert_equal src_st.atime, dst_st.atime
			assert_equal src_st.mtime, dst_st.mtime

			# :backupdest
			Pa.cp("a", "backup")
			Pa.cp("a", "backup", :backupdest)
			assert File.exists?("backup~")


			# :overwrite
			# cp a b_overwrite
			FileUtils.touch("file_overwrite")
			assert_raises Errno::EEXIST do Pa.cp("a", "file_overwrite") end
			Pa.cp("a", "file_overwrite", :overwrite)
			# cp name/ dir/name/
			assert_raises Errno::EEXIST do Pa.cp("dir", "destdir") end
			Pa.cp("dir", "destdir", :overwrite)
			open("destdir/dir/b"){|f| 
				assert_equal "guten", f.read}
			assert File.directory?("destdir/dir/dira")

			### :update
			Pa.cp("a", "update")

			# =
			oldinode = File.stat("update").inode
			Pa.cp("a", "update", :update)
			assert_equal oldinode, File.lstat("update").inode

			# >
			gwrite("a", "msg>")
			Pa.cp("a", "update", :update)
			assert_equal "msg>", gread("update")

			# msg<
			gwrite("update", "msg<")
			Pa.cp("a", "update", :update)
			assert_equal "msg<", gread("update")

			Pa.utime("update", nil, Time.now+60)
			Pa.cp("a", "update", :diff)
			assert_equal "msg>", gread("update")

		end # cleanup
	end # test__copy

	# need sudo
	def test_mknod 
		skip("not ready")
		Pa.mknod("console", :chardev, "/dev/console", mode:0777)
		assert_equal :chardev, Pa.type("console")
		#assert_equal 010777, Pa.lstat("console").mode
		assert_equal 020777, Pa.lstat("console").mode  # 02077 works

		Pa.mknod("fifo", :fifo)
		assert_equal :fifo, Pa.type("fifo")

		Pa.rmfile ["console", "fifo"]
	end # def test_mknod

end # class Test1
