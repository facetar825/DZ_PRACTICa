from decimal import Decimal
from django.test import Client, SimpleTestCase

from .forms import DeliveryForm


class DeliveryTests(SimpleTestCase):
    data = {"sender":"Иванов Иван Иванович", "phone":"+7 (900) 123-45-67",
            "origin":"Иркутск", "destination":"Москва", "weight":"10",
            "delivery_type":"standard", "promo_code":"", "agreement":"on"}

    def test_prices_promos_and_boundaries(self):
        for kind, price in [("standard","600.00"), ("express","900.00"), ("same_day","1200.00")]:
            form = DeliveryForm(dict(self.data, delivery_type=kind))
            self.assertTrue(form.is_valid(), form.errors)
            self.assertEqual(form.total(), Decimal(price))
        for promo, price in [("TOP5","570.00"), ("top10","540.00"), ("TOP15","510.00")]:
            form = DeliveryForm(dict(self.data, promo_code=promo))
            self.assertTrue(form.is_valid(), form.errors)
            self.assertEqual(form.total(), Decimal(price))
        for weight in ["0.1", "100"]:
            self.assertTrue(DeliveryForm(dict(self.data, weight=weight)).is_valid())
        for change in [
            {"weight":"0.09"}, {"weight":"100.01"}, {"destination":" ИРКУТСК "},
            {"delivery_type":"express","weight":"20.01"}, {"phone":"abc"},
            {"promo_code":"unknown"}, {"agreement":""}, {"delivery_type":"invalid"},
        ]:
            self.assertFalse(DeliveryForm(dict(self.data, **change)).is_valid())
        form = DeliveryForm(dict(self.data, weight="20", delivery_type="express"))
        self.assertTrue(form.is_valid())

    def test_render_result_and_preserve_invalid_values(self):
        response = self.client.post("/", self.data)
        self.assertContains(response, "600,00")
        response = self.client.post("/", dict(self.data, destination="Иркутск"))
        self.assertContains(response, "должны различаться")
        self.assertContains(response, "Иванов Иван Иванович")
        self.assertEqual(Client(enforce_csrf_checks=True).post("/", self.data).status_code, 403)
