<%@ Page Language="C#" AutoEventWireup="true"  CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        
                <div>
            <p>Server Name: <%= Environment.MachineName %></p>
            <p>Current Date and Time: <%= DateTime.Now.ToString() %></p>
        </div>

        <hr />
    <div>
    
        <p>An ASP.NET Web Forms website project that does not need to be built into a DLL is typically referred to as a &quot;Web Site&quot; project, as opposed to a &quot;Web Application&quot; project. In a Web Site project, the code-behind files are compiled dynamically at runtime, rather than being precompiled into a DLL.</p>
<h3 id="key-characteristics-of-a-web-site-project-">Key Characteristics of a Web Site Project:</h3>
<ol>
<li><strong>Dynamic Compilation</strong>: Code-behind files are compiled dynamically when the application is first accessed.</li>
<li><strong>No Project File</strong>: Unlike Web Application projects, Web Site projects do not have a <code>.csproj</code> or <code>.vbproj</code> file.</li>
<li><strong>Ease of Deployment</strong>: You can deploy the source files directly to the server without needing to compile them into a DLL.</li>
</ol>
<h3 id="creating-a-web-site-project-in-visual-studio-">Creating a Web Site Project in Visual Studio:</h3>
<ol>
<li>Open Visual Studio.</li>
<li>Go to <code>File</code> &gt; <code>New</code> &gt; <code>Web Site</code>.</li>
<li>Choose <code>ASP.NET Web Site</code> and select the desired language (C# or VB).</li>
<li>Specify the location where you want to create the project and click <code>OK</code>.</li>
</ol>
<h3 id="example-structure-of-a-web-site-project-">Example Structure of a Web Site Project:</h3>
<pre><code>/WebSite
    /App_Data
    /App_Themes
    /bin
    /Images
    /Scripts
    /Styles
    /UserControls
    /Default<span class="hljs-selector-class">.aspx</span>
    /Default<span class="hljs-selector-class">.aspx</span><span class="hljs-selector-class">.cs</span>
    /Web.config
</code></pre><h3 id="deploying-a-web-site-project-">Deploying a Web Site Project:</h3>
<ol>
<li><strong>Copy Files</strong>: Simply copy the entire project directory (excluding the <code>.vs</code> folder if present) to the target server.</li>
<li><strong>Configure IIS</strong>: Ensure that IIS is configured to serve ASP.NET applications and that the necessary features (like ASP.NET, CGI, ISAPI Extensions, etc.) are installed.</li>
</ol>
<h3 id="example-deployment-using-docker-">Example Deployment Using Docker:</h3>
<p>You can use the provided Dockerfile to deploy an ASP.NET Web Forms Web Site project. Here’s how you can modify the Dockerfile to copy your Web Site files:</p>
<pre><code class="lang-dockerfile"><span class="hljs-comment"># escape=`</span>
<span class="hljs-keyword">FROM</span> mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
SHELL [<span class="hljs-string">"powershell"</span>, <span class="hljs-string">"-command"</span>]

<span class="hljs-keyword">ENV</span> APPSETTING_DSN=<span class="hljs-string">'parameterise this'</span> 

<span class="hljs-keyword">RUN</span><span class="bash"> Install-WindowsFeature Web-ASP; `
</span>    Install-WindowsFeature Web-CGI; `
    Install-WindowsFeature Web-ISAPI-Ext; `
    Install-WindowsFeature Web-ISAPI-Filter; `
    Install-WindowsFeature Web-Includes; `
    Install-WindowsFeature Web-HTTP-Errors; `
    Install-WindowsFeature Web-Common-HTTP; `
    Install-WindowsFeature Web-Performance; `
    Install-WindowsFeature WAS; `
    Import-module IISAdministration; 

<span class="hljs-keyword">RUN</span><span class="bash"> md c:/msi; 
</span>
<span class="hljs-keyword">RUN</span><span class="bash"> Invoke-WebRequest <span class="hljs-string">'https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi'</span> -OutFile c:/msi/urlrewrite2.msi; `
</span>    Start-Process <span class="hljs-string">'c:/msi/urlrewrite2.msi'</span> <span class="hljs-string">'/qn'</span> -PassThru | Wait-Process; 

<span class="hljs-keyword">RUN</span><span class="bash"> Invoke-WebRequest <span class="hljs-string">'https://download.microsoft.com/download/1/E/7/1E7B1181-3974-4B29-9A47-CC857B271AA2/English/X64/msodbcsql.msi'</span> -OutFile c:/msi/msodbcsql.msi; 
</span>
<span class="hljs-keyword">RUN</span><span class="bash"> [<span class="hljs-string">"cmd"</span>, <span class="hljs-string">"/S"</span>, <span class="hljs-string">"/C"</span>, <span class="hljs-string">"c:\\windows\\syswow64\\msiexec"</span>, <span class="hljs-string">"/i"</span>, <span class="hljs-string">"c:\\msi\\msodbcsql.msi"</span>, <span class="hljs-string">"IACCEPTMSODBCSQLLICENSETERMS=YES"</span>, <span class="hljs-string">"ADDLOCAL=ALL"</span>, <span class="hljs-string">"/qn"</span>]; EXPOSE 80 
</span>
<span class="hljs-keyword">RUN</span><span class="bash"> Remove-Website -Name <span class="hljs-string">'Default Web Site'</span>; `
</span>    New-Website -Name <span class="hljs-string">'MyWebSite'</span> -Port <span class="hljs-number">80</span> -PhysicalPath <span class="hljs-string">'C:\inetpub\wwwroot\MyWebSite'</span> -ApplicationPool <span class="hljs-string">'.NET v4.5'</span>; 

<span class="hljs-comment"># Copy the Web Site files to the container</span>
<span class="hljs-keyword">COPY</span><span class="bash"> . /inetpub/wwwroot/MyWebSite</span>
</code></pre>
<h3 id="summary-">Summary:</h3>
<ul>
<li><strong>Web Site Project</strong>: No need to build into a DLL, dynamically compiled.</li>
<li><strong>Deployment</strong>: Copy files directly to the server or use a Docker container.</li>
<li><strong>Dockerfile</strong>: Modify to include necessary IIS features and copy Web Site files.</li>
</ul>
<p>By following these steps, you can deploy an ASP.NET Web Forms Web Site project that does not require pre-compilation into a DLL.</p>




    </div>
    </form>
</body>
</html>
