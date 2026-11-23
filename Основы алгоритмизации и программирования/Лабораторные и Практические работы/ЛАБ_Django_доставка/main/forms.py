import re
import unicodedata
from decimal import Decimal

from django import forms
from django.core.exceptions import ValidationError

PROMOS = {"TOP5": Decimal("0.05"), "TOP10": Decimal("0.10"), "TOP15": Decimal("0.15")}


class DeliveryForm(forms.Form):
    sender = forms.CharField(label="ФИО отправителя", max_length=150)
    phone = forms.CharField(label="Телефон", max_length=30)
    origin = forms.CharField(label="Город отправки", max_length=80)
    destination = forms.CharField(label="Город получения", max_length=80)
    weight = forms.DecimalField(label="Вес, кг", min_value=Decimal("0.1"),
                                max_value=100, decimal_places=2, max_digits=5)
    delivery_type = forms.ChoiceField(label="Тип доставки", choices=[
        ("standard", "Стандартная"), ("express", "Экспресс"), ("same_day", "В тот же день"),
    ])
    promo_code = forms.CharField(label="Промокод", max_length=20, required=False)
    agreement = forms.BooleanField(label="Согласен с условиями доставки")

    def clean_phone(self):
        value = self.cleaned_data["phone"]
        if not re.fullmatch(r"\+?[\d ()-]+", value) or not 10 <= len(re.sub(r"\D", "", value)) <= 15:
            raise ValidationError("Введите телефон из 10–15 цифр.")
        return value

    def clean_promo_code(self):
        value = self.cleaned_data["promo_code"].upper()
        if value and value not in PROMOS:
            raise ValidationError("Промокод не найден.")
        return value

    def clean(self):
        data = super().clean()
        normalize = lambda value: " ".join(unicodedata.normalize("NFKC", value).casefold().split())
        if data.get("origin") and data.get("destination") and normalize(data["origin"]) == normalize(data["destination"]):
            self.add_error("destination", "Города отправки и получения должны различаться.")
        if data.get("delivery_type") == "express" and data.get("weight", 0) > 20:
            self.add_error("weight", "Для экспресс-доставки вес не более 20 кг.")
        return data

    def total(self):
        data = self.cleaned_data
        multiplier = {"standard": Decimal("1"), "express": Decimal("1.5"), "same_day": Decimal("2")}
        discount = PROMOS.get(data["promo_code"], Decimal("0"))
        amount = (Decimal("300") + Decimal("30") * data["weight"]) * multiplier[data["delivery_type"]]
        return (amount * (1 - discount)).quantize(Decimal("0.01"), rounding="ROUND_HALF_UP")
