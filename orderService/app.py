import os
from datetime import datetime
from flask import Flask, jsonify, request
from extensions import db
from servicebus import publish_event
from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"]=os.getenv(
    "DATABASE_URI",
    "postgresql://admin:admin@localhost:5432/shop"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"]=False
db.init_app(app)

from models import Orders, Products

with app.app_context():
    db.create_all()

@app.route('/', methods=['GET'])
def get_products():
    products=Products.query.all()
    return jsonify([
        product.to_dict() for product in products
    ])

@app.route('/<int:id>', methods=['POST'])
def create_order(id):
    try:
        product = db.session.get(
            Products,
            id
        )
        if not product:
            return jsonify({"error":"Product not found"}), 404
        if product.amount <= 0:
            return jsonify({"error":"Product not available"}), 409
        data = request.get_json()
        if not data:
            return jsonify({"error":"json body not found"}), 400
        email = data.get('email')
        if not email:
            return jsonify({"error":"email required"}), 400
        product.amount-=1
        order = Orders(
            email=email,
            product_name=product.name,
            product_id=product.id,
            creation_time=datetime.now(),
            status="CREATED"
        )
        db.session.add(order)
        db.session.commit()
        publish_event("orders",
                      {
                          "event_type": "OrderCreated",
                          "order_id": order.id,
                          "product_name": product.name,
                          "product_id": product.id,
                          "price": product.price,
                          "email": order.email
                      })
        return jsonify({"success":"Order placed"}), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({"error":str(e)}), 500
    
@app.route('/orders/<int:id>',methods=["GET"])
def get_orders(id):
    order=db.session.get(
        Orders,
        id
    )
    if not order:
        return jsonify({"error":"Order not found"}), 404
    return jsonify(order.to_dict())

@app.route('/products/<int:id>', methods=["GET"])
def get_product(id):
    product = db.session.get(
        Products,
        id
    )
    if not product:
        return jsonify({"error": "Product not found"}), 404
    return jsonify(
        product.to_dict()
    )

@app.route('/products', methods=["POST"])
def create_product():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "json body required"}), 400 
        name = data.get("name")
        amount = data.get("amount")
        price = data.get("price")
        if not name or amount is None or price is None:
            return jsonify({"error": "name, amount and price required"}), 400
        product = Products(
            name=name,
            amount=amount,
            price=price
        )
        db.session.add(product)
        db.session.commit()
        return jsonify({"Success":"Product with id "+str(product.id)+" created"}), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({"error":str(e)}), 500
    
    
if __name__ == '__main__':
    app.run(
        host="0.0.0.0",
        port=8080,
        debug=True
    )