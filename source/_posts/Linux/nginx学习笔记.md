---
title: nginx学习笔记
date: 2023-06-11 17:12:21
tags:
---

## https server

```text
server {
        listen 端口 ssl http2;
        listen [::]:端口 ssl http2;
        server_name __domain_name__;
        ssl_certificate __cert_dir__/fullchain.cer;
        ssl_certificate_key __cert_dir__/__domain_name__.key;
        location / { 
                root /home/wwwroot/;
        }   
}
```

## alias / root

`alias`类似于`proxy_pass`，会自动把跟location match的部分从URI中删掉。而`root`仍然会保留location里的部分。

文档：<http://nginx.org/en/docs/http/ngx_http_core_module.html#alias>

参考：

<https://stackoverflow.com/questions/11570321/configure-nginx-with-multiple-locations-with-different-root-folders-on-subdomain>

<https://stackoverflow.com/questions/28130841/removing-start-of-path-from-nginx-proxy-pass>

[Remove path prefix during proxy_pass](https://mailman.nginx.org/pipermail/nginx/2016-February/049856.html)
