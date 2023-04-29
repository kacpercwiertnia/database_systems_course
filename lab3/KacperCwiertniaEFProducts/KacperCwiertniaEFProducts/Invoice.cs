using System;
namespace KacperCwiertniaEFProducts
{
	public class Invoice
	{
        public Invoice(){
            this.Products = new HashSet<Product>();
        }

        public int InvoiceID { get; set; }
        public int InvoiceNumber { get; set; }
        public int Quantity { get; set; }
        public virtual ICollection<Product> Products { get; set; }
	}
}

