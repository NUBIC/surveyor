class Redirector
    require "tempfile"
    attr_accessor "ruby"

    def initialize
        @ruby = "ruby"
        @script = tempfile
        @script.write <<-ruby
        stdout, stderr = ARGV.shift, ARGV.shift
        File::unlink out rescue nil
        File::unlink err rescue nil
        STDOUT.reopen(open(stdout,"a"))
        STDERR.reopen(open(stderr,"a"))
        system(ARGV.join(' '))
        ruby
        @script.close
    end

    def run command, redirects = {}
        stdout = redirects.values_at("stdout", :stdout, "o", :o, 1).compact.first
        tout = nil
        unless stdout
            tout = tempfile
            stdout = tout.path
        end

        stderr = redirects.values_at("stderr", :stderr, "e", :e, 2).compact.first
        terr = nil
        unless stderr
            terr = tempfile
            stderr = terr.path
        end

        system "#{ @ruby } #{ @script.path } #{ stdout } #{ stderr } #{ command }"
        ret = IO::read(stdout), IO::read(stderr), $?.exitstatus
        tout.close! if tout
        terr.close! if terr
        ret
    end

    def tempfile
        Tempfile::new(Process::pid.to_s << rand.to_s)
    end

end

#redirector = Redirector::new

#stdout, stderr, exitstatus = redirector.run "echo 42"
#p [stdout, stderr, exitstatus]

#redirector.run "ruby -cw bio_device.rb", 1 => "out", 2 => "err"
#p [IO::read("out"), IO::read("err")]