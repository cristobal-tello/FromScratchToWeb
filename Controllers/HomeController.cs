
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