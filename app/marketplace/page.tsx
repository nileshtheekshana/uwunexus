import { Store, Search, Filter, MessageCircle } from "lucide-react";

export default function MarketplacePage() {
  const products = [
    {
      id: 1,
      name: "Engineering Drawing Board",
      price: "Rs. 2500",
      condition: "Used - Good",
      seller: "Kamal P.",
      image: "linear-gradient(to bottom right, #3b82f6, #2dd4bf)"
    },
    {
      id: 2,
      name: "Casio fx-991EX Calculator",
      price: "Rs. 4000",
      condition: "Like New",
      seller: "Nimali S.",
      image: "linear-gradient(to bottom right, #f59e0b, #ef4444)"
    },
    {
      id: 3,
      name: "Introduction to Algorithms (3rd Ed)",
      price: "Rs. 3500",
      condition: "Used - Acceptable",
      seller: "Ruwan J.",
      image: "linear-gradient(to bottom right, #8b5cf6, #d946ef)"
    },
    {
      id: 4,
      name: "Arduino Starter Kit",
      price: "Rs. 6000",
      condition: "Brand New",
      seller: "Amal M.",
      image: "linear-gradient(to bottom right, #10b981, #3b82f6)"
    }
  ];

  return (
    <div className="container py-8">
      <div className="flex justify-between items-center mb-8 flex-wrap gap-4">
        <div>
          <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
            <Store size={36} className="text-success" />
            Sarasawi Alewisala
          </h1>
          <p className="text-muted">Trusted student-to-student marketplace.</p>
        </div>
        <button className="btn btn-primary" style={{ backgroundColor: 'var(--success)' }}>
          + Create Listing
        </button>
      </div>

      {/* Search and Filters */}
      <div className="card mb-8 p-4 flex flex-wrap gap-4 items-center">
        <div className="flex-1" style={{ minWidth: '250px', position: 'relative' }}>
          <Search size={18} className="text-muted" style={{ position: 'absolute', left: '1rem', top: '50%', transform: 'translateY(-50%)' }} />
          <input 
            type="text" 
            placeholder="Search for items..." 
            className="form-input" 
            style={{ paddingLeft: '2.5rem' }} 
          />
        </div>
        <button className="btn btn-secondary">
          <Filter size={18} />
          Categories
        </button>
      </div>

      <div className="grid grid-cols-1 md-grid-cols-2 lg-grid-cols-4 gap-6">
        {products.map((product) => (
          <div key={product.id} className="card p-0 overflow-hidden flex flex-col" style={{ padding: 0 }}>
            {/* Image Placeholder */}
            <div style={{ background: product.image, height: '180px', width: '100%' }}></div>
            
            <div className="p-4 flex flex-col flex-1">
              <h3 className="font-bold text-lg mb-1">{product.name}</h3>
              <div className="text-xl font-bold text-success mb-2">{product.price}</div>
              
              <div className="flex flex-col gap-1 text-sm text-muted mb-4">
                <span>Condition: <strong className="text-foreground">{product.condition}</strong></span>
                <span>Seller: {product.seller}</span>
              </div>
              
              <button className="btn mt-auto w-full" style={{ border: '1px solid var(--border)', display: 'flex', justifyContent: 'center' }}>
                <MessageCircle size={16} />
                Contact Seller
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
