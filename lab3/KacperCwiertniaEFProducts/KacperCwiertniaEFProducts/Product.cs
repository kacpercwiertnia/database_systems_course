using System;
namespace KacperCwiertniaEFProducts
{
	public class Product
	{
        public Product(){
            this.Invoices = new HashSet<Invoice>();
        }

        public int ProductID { get; set; }
		public string ProductName { get; set; }
		public int UnitsOnStock { get; set; }
        public virtual ICollection<Invoice> Invoices { get; set; }
    }
}

