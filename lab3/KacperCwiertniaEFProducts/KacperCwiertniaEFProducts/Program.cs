namespace KacperCwiertniaEFProducts
{
    public class Program
    {
        static void Main(string[] args)
        {
            ProductContext productContext = new ProductContext();
            Company company1 = new Customer { CompanyName = "firma1", Street = "Słoneczna", City="Kraków", ZipCode="32-012", discount = 0.2 };
            Company company2 = new Customer { CompanyName = "firma2", Street = "Budryka", City = "Kraków", ZipCode = "35-122", discount = 0.1 };
            Company company3 = new Customer { CompanyName = "firma3", Street = "Lea", City = "Kraków", ZipCode = "35-222", discount = 0.5 };
            Company company4 = new Supplier { CompanyName = "firma4", Street = "Karmelicka", City = "Kraków", ZipCode = "35-282", bankAccountNumber = "000000000001" };
            Company company5 = new Supplier { CompanyName = "firma5", Street = "Batorego", City = "Kraków", ZipCode = "35-132", bankAccountNumber = "000012310001" };
            Company company6 = new Supplier { CompanyName = "firma6", Street = "Kremerowksa", City = "Kraków", ZipCode = "35-332", bankAccountNumber = "123100000001" };
            productContext.Companies.Add(company1);
            productContext.Companies.Add(company2);
            productContext.Companies.Add(company3);
            productContext.Customers.Add((Customer)company1);
            productContext.Customers.Add((Customer)company2);
            productContext.Customers.Add((Customer)company3);
            productContext.Companies.Add(company4);
            productContext.Companies.Add(company5);
            productContext.Companies.Add(company6);
            productContext.Suppliers.Add((Supplier)company4);
            productContext.Suppliers.Add((Supplier)company5);
            productContext.Suppliers.Add((Supplier)company6);
            productContext.SaveChanges();

            var query = from comp in productContext.Companies
                        select comp;

            Console.WriteLine("Poniżej lista firm zarejestrowanych w naszej bazie danych");
            foreach (var comp in query)
            {
                Console.WriteLine(comp.CompanyName);
            }

            var query2 = from comp in productContext.Suppliers.OfType<Supplier>()
                        select comp;

            Console.WriteLine("Poniżej lista dostawców zarejestrowanych w naszej bazie danych wraz z numerami kont bankowych");
            foreach (var comp in query2)
            {
                Console.WriteLine(comp.CompanyName + " " + ((Supplier)comp).bankAccountNumber);
            }

            var query3 = from comp in productContext.Customers
                        select comp;

            Console.WriteLine("Poniżej lista klientów zarejestrowanych w naszej bazie danych wraz z wartością znizki");
            foreach (var comp in query3)
            {
                Console.WriteLine(comp.CompanyName + " " + comp.discount);
            }
        }
    }
}