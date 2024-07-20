<!DOCTYPE html>
<html lang="en">
<title>W3.CSS Template</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<style>
  body {
    font-family: "Lato", sans-serif
  }

  .mySlides {
    display: none
  }
</style>

<body>
<%
CONFIG_FILE_PATH="web.config"  
Function GetConfigValue(sectionName, attrName)
    Dim oXML, oNode, oChild, oAttr, dsn
    Set oXML=Server.CreateObject("Microsoft.XMLDOM")
    oXML.Async = "false"
    oXML.Load(Server.MapPath(CONFIG_FILE_PATH))
    Set oNode = oXML.GetElementsByTagName(sectionName).Item(0) 
    Set oChild = oNode.GetElementsByTagName("add")
    ' Get the first match
    For Each oAttr in oChild 
        If  oAttr.getAttribute("key") = attrName then
            dsn = oAttr.getAttribute("value")
            GetConfigValue = dsn
            Exit Function
        End If
    Next
End Function  
%>  
  <!--#include file='header.asp'-->

  <!-- Page content -->
  <div class="w3-content" style="max-width:2000px;margin-top:46px">

    <p>Server Name: <%= Request.ServerVariables("SERVER_NAME") %></p>
    <p>Current Date and Time: <%= Now() %></p>

    <p>Classic ASP (Active Server Pages) is a server-side scripting environment that allows you to create dynamic web pages using VBScript or JScript. Below is an example of how to write a server-side script in Classic ASP to display the server name and the current date and time.</p>
    <h3 id="example-classic-asp-script">Example Classic ASP Script</h3>
    <p>Create a new file named <code>default.asp</code> and add the following code:</p>
    <pre><code class="lang-asp"><span class="xml"><span class="hljs-tag">&lt;<span class="hljs-name">%</span></span></span><span class="ruby">@ Language=<span class="hljs-string">"VBScript"</span> </span><span class="xml"><span class="hljs-tag">%&gt;</span>
    <span class="hljs-meta">&lt;!DOCTYPE html&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">html</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">head</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">title</span>&gt;</span>Server Info<span class="hljs-tag">&lt;/<span class="hljs-name">title</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">head</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">body</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">p</span>&gt;</span>Server Name: <span class="hljs-tag">&lt;<span class="hljs-name">%=</span></span></span><span class="ruby"> Request.ServerVariables(<span class="hljs-string">"SERVER_NAME"</span>) </span><span class="xml"><span class="hljs-tag">%&gt;</span><span class="hljs-tag">&lt;/<span class="hljs-name">p</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">p</span>&gt;</span>Current Date and Time: <span class="hljs-tag">&lt;<span class="hljs-name">%=</span></span></span><span class="ruby"> Now() </span><span class="xml"><span class="hljs-tag">%&gt;</span><span class="hljs-tag">&lt;/<span class="hljs-name">p</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">body</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">html</span>&gt;</span></span>
    </code></pre>
    <h3 id="explanation">Explanation</h3>
    <ul>
    <li><strong><code>&lt;%@ Language=&quot;VBScript&quot; %&gt;</code></strong>: Specifies that the scripting language used in the page is VBScript.</li>
    <li><strong><code>Request.ServerVariables(&quot;SERVER_NAME&quot;)</code></strong>: Retrieves the server name.</li>
    <li><strong><code>Now()</code></strong>: Returns the current date and time.</li>
    </ul>
    <h3 id="summary">Summary</h3>
    <ol>
    <li><strong>Create <code>default.asp</code></strong>: Add the provided code to display the server name and current date and time.</li>
    <li><strong>Deploy</strong>: Place the <code>default.asp</code> file in your web server&#39;s root directory or appropriate folder.</li>
    </ol>
    <p>This script will dynamically display the server name and the current date and time when accessed via a web browser.</p>
    

  </div>

  <!-- End Page Content -->
  </div>

  <!-- Footer -->
  <footer class="w3-container w3-padding-64 w3-center w3-opacity w3-light-grey w3-xlarge">
    <i class="fa fa-facebook-official w3-hover-opacity"></i>
    <i class="fa fa-instagram w3-hover-opacity"></i>
    <i class="fa fa-snapchat w3-hover-opacity"></i>
    <i class="fa fa-pinterest-p w3-hover-opacity"></i>
    <i class="fa fa-twitter w3-hover-opacity"></i>
    <i class="fa fa-linkedin w3-hover-opacity"></i>
  </footer>

  <script>
    // Automatic Slideshow - change image every 4 seconds
    var myIndex = 0;
    carousel();

    function carousel() {
      var i;
      var x = document.getElementsByClassName("mySlides");
      for (i = 0; i < x.length; i++) {
        x[i].style.display = "none";
      }
      myIndex++;
      if (myIndex > x.length) { myIndex = 1 }
      x[myIndex - 1].style.display = "block";
      setTimeout(carousel, 4000);
    }

    // Used to toggle the menu on small screens when clicking on the menu button
    function myFunction() {
      var x = document.getElementById("navDemo");
      if (x.className.indexOf("w3-show") == -1) {
        x.className += " w3-show";
      } else {
        x.className = x.className.replace(" w3-show", "");
      }
    }

    // When the user clicks anywhere outside of the modal, close it
    var modal = document.getElementById('ticketModal');
    window.onclick = function (event) {
      if (event.target == modal) {
        modal.style.display = "none";
      }
    }
  </script>

</body>

</html>
