import React from 'react';
import { Link } from 'react-router-dom';
import { Product } from '../types/database';

interface ProductCardProps {
  product: Product;
}

export default function ProductCard({ product }: ProductCardProps) {
  const discountedPrice = product.price - (product.price * (product.discount_percent / 100)) - product.discount_amount;

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <div className="aspect-w-1 aspect-h-1 w-full overflow-hidden">
        <img
          src={product.image_url || 'https://images.pexels.com/photos/4464821/pexels-photo-4464821.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'}
          alt={product.name}
          className="w-full h-full object-cover object-center"
        />
      </div>
      <div className="p-4">
        <h3 className="text-lg font-medium text-gray-900">{product.name}</h3>
        <p className="mt-1 text-sm text-gray-500 line-clamp-2">{product.description}</p>
        <div className="mt-2 flex items-center justify-between">
          <div>
            {product.discount_percent > 0 || product.discount_amount > 0 ? (
              <>
                <span className="text-lg font-bold text-gray-900">${discountedPrice.toFixed(2)}</span>
                <span className="ml-2 text-sm text-gray-500 line-through">${product.price.toFixed(2)}</span>
              </>
            ) : (
              <span className="text-lg font-bold text-gray-900">${product.price.toFixed(2)}</span>
            )}
          </div>
          <span className={`px-2 py-1 text-xs font-semibold rounded ${
            product.available_count > 0 ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
          }`}>
            {product.available_count > 0 ? 'In Stock' : 'Out of Stock'}
          </span>
        </div>
        <Link
          to={`/products/${product.id}`}
          className="mt-4 block w-full text-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
        >
          View Details
        </Link>
      </div>
    </div>
  );
}