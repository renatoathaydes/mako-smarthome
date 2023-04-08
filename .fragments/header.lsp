<!DOCTYPE html>
<html>
  <head>
     <meta charset="UTF-8"/>
     <title>SmartHome</title>
     <link rel="stylesheet" href="/smarthome/style.css">
  </head>
  <body>
<header class='top-header'>
    My SmartHome
</header>
<nav>
 <ul>
  <li class='<?lsp= homePageActive or "" ?>'><a href="/smarthome/index.lsp">Home</a></li>
  <li class='<?lsp= chartsPageActive or "" ?>'><a href="/smarthome/charts.lsp">Charts</a></li>
  <li class='<?lsp= controlPageActive or "" ?>'><a href="/smarthome/control.lsp">Control</a></li>
 </ul>
</nav>
<main>