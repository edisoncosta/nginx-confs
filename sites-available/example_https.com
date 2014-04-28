# example.com https

#
# Redirect all www to non-www
#
server {
    include /etc/nginx/includes/listen80.conf;
    include /etc/nginx/includes/listen443.conf;

	# other associated domains
    server_name  www.example.com example2.com www.example2.com;

	# 301s can't easily be undone. 302 until we're sure.
	return 302 https://example.com$request_uri;

	# SSL with a chained cert and Perfect Foward Secrecy
	ssl on;
    ssl_certificate      /etc/nginx/ssl/example.com/example.com.chained.crt;
    ssl_certificate_key  /etc/nginx/ssl/example.com/example.com.key;
	ssl_prefer_server_ciphers on;
	ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
	ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:RC4-SHA;
}

#
# Redirect all non-encrypted to encrypted
#
server {
    include /etc/nginx/includes/listen80.conf;

	server_name          example.com;

    return 302 https://example.com$request_uri;
}

#
# And here's the final block. The SSL block should really be an include as well.
#
server {
    include /etc/nginx/includes/listen443.conf;
    
    server_name          example.com;
    root /var/www/example.com;
	
	# SSL with a chained cert and Perfect Foward Secrecy
	ssl on;
    ssl_certificate      /etc/nginx/ssl/example.com/example.com.chained.crt;
    ssl_certificate_key  /etc/nginx/ssl/example.com/example.com.key;
	ssl_prefer_server_ciphers on;
	ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
	ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:RC4-SHA;

    access_log   /var/log/nginx/example.com.access.log;
	error_log    /var/log/nginx/example.com.error.log debug;
		
	include /etc/nginx/includes/wordpress.conf;
}