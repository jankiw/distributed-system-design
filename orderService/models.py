from sqlalchemy import Column, String, DateTime, Integer, Float
from sqlalchemy.orm import validates
from extensions import db

class Orders(db.Model):
    __tablename__ = 'orders'
    id = Column(Integer, primary_key=True)
    email = Column(String(50))
    product_name = Column(String(50))
    product_id = Column(Integer)
    status = Column(String, default="CREATED")
    creation_time = Column(DateTime)
    
    @validates('email')
    def validate_email(self, key, value):
        if "@" not in value:
            raise ValueError("failed simple email validation")
        return value
    
    def to_dict(self):
        return{
            "id":self.id,
            "email":self.email,
            "product_name":self.product_name,
            "product_id":self.product_id,
            "status":self.status,
            "creation_time":self.creation_time
        }
    


class Products(db.Model):
    __tablename__ = 'products'
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    amount = Column(Integer)
    price = Column(Float)

    def to_dict(self):
        return {
            "id":self.id,
            "name":self.name,
            "amount":self.amount,
            "price":self.price
        }