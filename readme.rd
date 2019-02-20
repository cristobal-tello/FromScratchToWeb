FromScratchToWeb is a project that want's to show you how to build an ASP.NET Core app without any wizards and from a simple console application.

1) Type 'dotnet new console' to create a basic .cs file and .csproj file
2) Open .csproj file on Visual Studio/Code and modify Program.cs file like this:

using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using System.IO;

public class Program
{
    public static void Main(string[] args)
    {
        var config = new ConfigurationBuilder().AddCommandLine(args).Build();
        var host = new WebHostBuilder()
            .UseContentRoot(Directory.GetCurrentDirectory())
            .UseKestrel()
            .UseStartup<Startup>()
            .UseConfiguration(config)
            .Build();
        host.Run();
    }
}

3) Add new 'Startup.cs' file with next code:

using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

public class Startup
{
    public Startup(IHostingEnvironment env)
    {
    }
    public void Configure(IApplicationBuilder app,IHostingEnvironment env, ILoggerFactory loggerFactory)
    {
        app.Run(async (context) =>
        {
            await context.Response.WriteAsync("Hello, world!");
        });
    }
}

4) Add next NuGet packages (2.1.0)
Microsoft.AspNetCore
Microsoft.AspNetCore.Server.Kestrel
Microsoft.Extensions.Configuration.CommandLine
Microsoft.AspNetCore.StaticFiles

5) Try to compile, and run and follow screen instrucctions to test if it works
Or from console, use:
dotnet restore
dotnet run

6) Edit .csproj file with notepad and modify next line:

<Project Sdk="Microsoft.NET.Sdk">
to
<Project Sdk="Microsoft.NET.Sdk.Web">


7) To prepare to use MVC Framework, add Microsoft.AspNetCore.Mvc NuGet package

8) Prepare to add MVC Framework on Startup.cs file

using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
public class Startup
{
    public Startup(IHostingEnvironment env)
    {
    }
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddMvc();
    }

    public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
    {
        app.UseMvc(routes =>
        {
            routes.MapRoute("default",
            template: "{controller=Home}/{action=Index}/{id?}");
        });
    }
}

9) Adding controller. Controllers needs to follow next rule:
	a) Accept input from HTTP requests.
	b) Delegate the input to service classes that are written without regard for HTTP transport or JSON parsing.
	c) Return an appropriate response code and body.
	d) Controllers should be very as possible

10) Create a Controllers folder and add new file called HomeController.cs

using Microsoft.AspNetCore.Mvc;

namespace Controllers
{
    public class HomeController : Controller
    {
        public string Index()
        {
            return "Hello World";
        }
    }
}

11) To add a model, create a Models folder and add StockQuote.cs  file

namespace Models
{
    public class StockQuote
    {
        public string Symbol { get; set; }
        public int Price { get; set; }
    }
}

12) Add a view to our Home Controller. Create a Index.cshtml fie in a new Views/Home folder with this content:

<html>
<head>
    <title>Hello world</title>
</head>
<body>
    <h1>Hello World</h1>
    <div>
        <h2>Stock Quote</h2>
        <div>
            Symbol: @Model.Symbol<br />
            Price: $@Model.Price<br />
        </div>
    </div>
</body>

13) Modify our Home controller to create a model and use the view to render it into the browser like this:

using Microsoft.AspNetCore.Mvc;
using Models;
using System.Threading.Tasks;

namespace Controllers
{
    public class HomeController : Controller
    {
        public async Task<IActionResult> Index()
        {
            var model = new StockQuote
            {
                Symbol = "HLLO",
                Price = 3200
            };
            return View(model);
        }
    }
}

14) Improving Startup.cs file to add envriorment values, loggers and more error info while we're developing

using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

public class Startup
{
    public IConfiguration Configuration { get; set; }
    public Startup(IHostingEnvironment env)
    {
        var builder = new ConfigurationBuilder().SetBasePath(env.ContentRootPath).AddEnvironmentVariables();
        Configuration = builder.Build();
    }
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddMvc();
    }

    public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
    {
        loggerFactory.AddConsole();
        loggerFactory.AddDebug();

        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        app.UseMvc(routes =>
        {
            routes.MapRoute("default",
            template: "{controller=Home}/{action=Index}/{id?}");
        });

    }
}

15) Create new API Controller :

using Microsoft.AspNetCore.Mvc;
using Models;

namespace Controllers
{
    [Route("api/test")]
    public class  ApiController : Controller
    {
        [HttpGet]
        public IActionResult GetTest()
        {
            return this.Ok(new StockQuote
            {
                Symbol = "API",
                Price = 9999
            });
        }
    }
}

16) Check if works, compile and run the app and go to http://localhost:<port>/api/test. A JSon file must appears on the browser.

17) Modify our Index.cshtml file to use previous API in a SPA page style:

<html>
<head>
    <title>Hello world</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js">
    </script>
    <script src="/Scripts/hello.js"></script>
</head>
<body>
    <h1>Hello World</h1>
    <div>
        <h2>Stock Quote</h2>
        <div>
            Symbol: @Model.Symbol<br />
            Price: $@Model.Price<br />
        </div>
    </div>
    <br />
    <div>
        <p class="quote-symbol">The Symbol is </p>
        <p class="quote-price">The price is $</p>
    </div>
</body>
</html>

18) Create a wwwroot folder. Inside this folder created another folder called Scripts and add hello.js file with this content:

$(document).ready(function () {
    $.ajax({
        url: "/api/test"
    }).then(function (data) {
        $('.quote-symbol').append(data.symbol);
        $('.quote-price').append(data.price);
    });
})