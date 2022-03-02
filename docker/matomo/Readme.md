# Usage and Configure

[参考文档](https://tech.weread.qq.com/matomo-best-practices/)

流量统计和用户行为分析记录的工具

作为一套基于 PHP 与 MySQL 的网页流量统计和分析平台，它的大部分功能已经开源，并且做了很好的封装，可以轻松地进行私有化部署，它的功能主要分成两块：

收集并存储页面访问数据，主要是用户信息，如设备型号、分辨率、用户地区、来源，以及页面信息，如页面访问路径、访问操作等。
对收集起来的数据进行指标量化并可视化的展示，例如用户设备型号分布、地区分布、某个页面的浏览人数、访问最多的页面、某个用户在某个页面的访问路径和具体操作等，并且在收集数据时，Matomo 会有大量的策略保护用户隐私，例如上报 IP 时隐藏最后一位字节等。
在实际使用时，用户信息的上报以及页面的访问路径，只需要安装并引入 Matomo 即可实现，无需额外的配置。但是开发者可以通过接口增强上报的数据，例如上报某个弹窗的展示，或者上报某个请求的结果，这样最终可以在平台上展示出完整的用户访问路径和操作，结合业务日志，可以很准确地定位问题以及还原问题的触发路径。




```
docker pull matomo:4.5.0-fpm-alpine
docker pull nginx:1.21.4-alpine
docker pull mariadb:10.7.1-focal
```

- 解决在 Docker 中部署 Matomo 的问题
  - 解决配置丢失的问题
  - 解决子目录部署的问题
  - 无法显示城市信息
- 前端引入追踪器的问题
  - 页面引入追踪器
  - 自动记录 Vue SPA 的页面跳转

- 自动记录 JS 错误
- 主动上报更多操作
- 请求失败自动上报
- 设置中文

  ```
  登录Matomo（之前叫Piwik）
  点击右上角的齿轮小图标，进入设置界面
  点击左菜单：Personal ==> settings
  设置中文（Language表单项）
  ```

- 自定义维度
```
itemId
packId
sessionId
proId
用户名 userEname
appId

```

- [插件-自定义变量](https://plugins.matomo.org/CustomVariables)
- [FAQ-如何添加超过默认的 5 个自定义变量？](https://matomo.org/faq/how-to/faq_17931/)
- [自定义变量分析](https://matomo.org/docs/custom-variables/)
- [插件-自定义维度](https://plugins.matomo.org/CustomDimensions)
- [插件-Js跟踪器自定义](https://plugins.matomo.org/JsTrackerCustom)
- [开发-Matomo开发者](https://developer.matomo.org/develop)
- [API参考-JavaScript 跟踪客户端](https://developer.matomo.org/api-reference/tracking-javascript)
- [使用手册-JavaScript 跟踪客户端](https://developer.matomo.org/guides/tracking-javascript-guide)


计划：
1. 本地测试
2. 自定义参数
3. 前台将自定义参数追加到上报请求中传到服务器
4. 服务器处理自定义参数
5. 将自定义参数存储到数据库
6. 上线试运行，部署到线上环境


```php
<!-- Matomo -->
<script>
  var _paq = window._paq = window._paq || [];

  function getQueryVariable(variable)
  {
      var query = window.location.search.substring(1);
      var vars = query.split("&");
      for (var i=0;i<vars.length;i++) {
              var pair = vars[i].split("=");
              if(pair[0] == variable){return pair[1];}
      }
      return "";
  }

  window.onload = function(){   
      /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
      _paq.push(["setDocumentTitle", document.domain + "/" + document.title]);
      
      /* itemId */ 
      _paq.push(['setCustomDimension', 1, getQueryVariable("itemId")]);
      /* packId */ 
      _paq.push(['setCustomDimension', 2, getQueryVariable("packId")]);
      /* sessionId */ 
      _paq.push(['setCustomDimension', 3, getQueryVariable("sessionId")]);
      /* proId */ 
      _paq.push(['setCustomDimension', 4, getQueryVariable("proId")]);
      /* userEname */ 
      _paq.push(['setCustomDimension', 5, $("#headerLogin").text().indexOf("您好，")>=0?$("#headerLogin").text().replace("您好，",""):""]);
      /* appId */ 
      _paq.push(['setCustomDimension', 6, "qyy"]);

      _paq.push(['trackPageView']);
      _paq.push(['enableLinkTracking']);  

      var u="//mstest.unibid.cn/matomo/";
      _paq.push(['setTrackerUrl', u+'matomo.php']);
      _paq.push(['setSiteId', '1']);
      var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
      g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
  }

</script>
<!-- End Matomo Code -->
```