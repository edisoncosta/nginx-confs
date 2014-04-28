# example.com http

server {
    include /etc/nginx/includes/listen80.conf;
    server_name  www.example.com example2.com www.example2.com;
    return       301 $scheme://example.com$request_uri;
}

server {
    include /etc/nginx/includes/listen80.conf;
	
	server_name example.com;
	root /var/www/example.com;
	
	access_log   /var/log/nginx/example.com.access.log;
	error_log    /var/log/nginx/example.com.error.log debug;
		
	include /etc/nginx/includes/wordpress.conf;
}