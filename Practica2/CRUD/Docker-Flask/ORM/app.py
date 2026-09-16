from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from functools import wraps
from itsdangerous import URLSafeTimedSerializer, SignatureExpired, BadTimeSignature
import os

app = Flask(__name__)

# 1. Configuración
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
# Usamos variables de entorno para el secreto (Requisito de la rúbrica)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'clave_secreta_desarrollo')

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
serializer = URLSafeTimedSerializer(app.config['SECRET_KEY'])

# 2. Modelos de la Base de Datos
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    password = db.Column(db.String(60), nullable=False)
    # Relación: Un usuario puede tener muchos productos en su inventario
    products = db.relationship('Product', backref='owner', lazy=True)

class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    quantity = db.Column(db.Integer, nullable=False, default=0)
    price = db.Column(db.Float, nullable=False, default=0.0)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

# 3. Decorador para proteger rutas con Token (Sesiones Seguras)
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"message": "Falta el token de sesión (Authorization Header)"}), 401
        try:
            # El token viene en formato "Bearer <token>"
            token = token.split(" ")[1]
            # Expira en 3600 segundos (1 hora)
            data = serializer.loads(token, max_age=3600)
            current_user = User.query.get(data['user_id'])
        except SignatureExpired:
            return jsonify({"message": "El token ha expirado"}), 401
        except (BadTimeSignature, IndexError):
            return jsonify({"message": "Token inválido"}), 401
        
        return f(current_user, *args, **kwargs)
    return decorated

# 4. Rutas Públicas (Auth)
@app.route('/')
def hello():
    return jsonify({"message": "API de Inventario Funcionando"})

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if User.query.filter_by(username=username).first():
        return jsonify({"message": "El usuario ya existe"}), 400

    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
    new_user = User(username=username, password=hashed_password)
    
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": "Usuario creado exitosamente"}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username).first()

    if user and bcrypt.check_password_hash(user.password, password):
        # Generar token de sesión
        token = serializer.dumps({'user_id': user.id})
        return jsonify({
            "status": "success",
            "message": "Login exitoso",
            "token": token,
            "username": user.username
        }), 200
    else:
        return jsonify({"status": "error", "message": "Credenciales inválidas"}), 401

# 5. Rutas Privadas (CRUD de Inventario)
@app.route('/products', methods=['POST'])
@token_required
def create_product(current_user):
    data = request.get_json()
    new_product = Product(
        name=data['name'],
        quantity=data.get('quantity', 0),
        price=data.get('price', 0.0),
        owner=current_user
    )
    db.session.add(new_product)
    db.session.commit()
    return jsonify({"message": "Producto creado", "product_id": new_product.id}), 201

@app.route('/products', methods=['GET'])
@token_required
def get_products(current_user):
    products = Product.query.filter_by(user_id=current_user.id).all()
    output = []
    for prod in products:
        output.append({
            "id": prod.id,
            "name": prod.name,
            "quantity": prod.quantity,
            "price": prod.price
        })
    return jsonify({"products": output}), 200

@app.route('/products/<int:id>', methods=['PUT'])
@token_required
def update_product(current_user, id):
    product = Product.query.filter_by(id=id, user_id=current_user.id).first()
    if not product:
        return jsonify({"message": "Producto no encontrado o sin permisos"}), 404

    data = request.get_json()
    product.name = data.get('name', product.name)
    product.quantity = data.get('quantity', product.quantity)
    product.price = data.get('price', product.price)
    
    db.session.commit()
    return jsonify({"message": "Producto actualizado"}), 200

@app.route('/products/<int:id>', methods=['DELETE'])
@token_required
def delete_product(current_user, id):
    product = Product.query.filter_by(id=id, user_id=current_user.id).first()
    if not product:
        return jsonify({"message": "Producto no encontrado o sin permisos"}), 404

    db.session.delete(product)
    db.session.commit()
    return jsonify({"message": "Producto eliminado"}), 200

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000, debug=True)