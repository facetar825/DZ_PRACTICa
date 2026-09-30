from flask import Flask, render_template, request, session, redirect, url_for, flash

app = Flask(__name__)
app.secret_key = 'super-secret-key-change-in-production'  # Обязательно для сессий!

# Каталог товаров (список словарей)
PRODUCTS = [
    {"id": 1, "name": "Ноутбук", "price": 75000, "category": "Электроника"},
    {"id": 2, "name": "Смартфон", "price": 45000, "category": "Электроника"},
    {"id": 3, "name": "Наушники", "price": 8000, "category": "Электроника"},
    {"id": 4, "name": "Книга «Python»", "price": 1500, "category": "Книги"},
    {"id": 5, "name": "Кружка", "price": 500, "category": "Посуда"},
    {"id": 6, "name": "Рюкзак", "price": 3500, "category": "Аксессуары"},
]


# Вспомогательная функция: получить товар по id
def get_product(product_id):
    return next((p for p in PRODUCTS if p["id"] == product_id), None)


# Вспомогательная функция: посчитать статистику корзины
def get_cart_stats():
    cart = session.get('cart', {})
    total_items = sum(cart.values())  # Всего штук
    unique_items = len(cart)  # Уникальных позиций
    total_price = 0

    for pid_str, qty in cart.items():
        product = get_product(int(pid_str))
        if product:
            total_price += product["price"] * qty

    return {
        "total_items": total_items,
        "unique_items": unique_items,
        "total_price": total_price
    }


# 1. КАТАЛОГ ТОВАРОВ
@app.route('/')
def index():
    stats = get_cart_stats()
    return render_template('index.html', products=PRODUCTS, stats=stats)


# 2. ДОБАВЛЕНИЕ ТОВАРА
@app.route('/add/<int:product_id>', methods=['POST'])
def add_to_cart(product_id):
    product = get_product(product_id)
    if not product:
        flash('Товар не найден', 'error')
        return redirect(url_for('index'))

    cart = session.get('cart', {})
    pid = str(product_id)  # JSON-ключи всегда строки

    # Если товар уже в корзине — увеличиваем количество
    cart[pid] = cart.get(pid, 0) + 1

    session['cart'] = cart
    session.modified = True  # Говорим Flask пересохранить сессию

    flash(f'«{product["name"]}» добавлен в корзину', 'success')
    return redirect(url_for('index'))


# 3. ПРОСМОТР КОРЗИНЫ
@app.route('/cart')
def cart_view():
    cart = session.get('cart', {})
    cart_items = []

    for pid_str, qty in cart.items():
        product = get_product(int(pid_str))
        if product:
            cart_items.append({
                "product": product,
                "quantity": qty,
                "subtotal": product["price"] * qty
            })

    stats = get_cart_stats()
    return render_template('cart.html', cart_items=cart_items, stats=stats)


# 4. УДАЛЕНИЕ ТОВАРА (убирает позицию целиком)
@app.route('/remove/<int:product_id>', methods=['POST'])
def remove_from_cart(product_id):
    cart = session.get('cart', {})
    pid = str(product_id)

    if pid in cart:
        product = get_product(product_id)
        name = product["name"] if product else "Товар"
        del cart[pid]
        session['cart'] = cart
        session.modified = True
        flash(f'«{name}» удалён из корзины', 'success')

    return redirect(url_for('cart_view'))


# 5. ОЧИСТКА КОРЗИНЫ (с подтверждением на странице)
@app.route('/clear', methods=['POST'])
def clear_cart():
    session.pop('cart', None)  # Удаляем корзину из сессии
    session.modified = True
    flash('Корзина очищена', 'success')
    return redirect(url_for('cart_view'))


# 6. СТАТИСТИКА (отдельная страница)
@app.route('/stats')
def stats_view():
    stats = get_cart_stats()
    return render_template('cart.html', cart_items=[], stats=stats, show_stats_only=True)


if __name__ == '__main__':
    app.run(debug=True)