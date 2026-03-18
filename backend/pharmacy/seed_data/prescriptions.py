PRESCRIPTIONS = [
    # 1. حالة برد شديد
    {
        "patient_name": "أحمد محمد السيد",
        "patient_phone": "01112345678",
        "doctor_name": "د. محمد عبدالرحمن",
        "notes": "المريض يعاني من برد شديد مع ارتفاع في درجة الحرارة وكحة مستمرة",
        "items": [
            {"product_name": "Comtrex", "quantity": 1, "dosage": "قرص كل 8 ساعات", "duration": "5 أيام"},
            {"product_name": "Congestal", "quantity": 1, "dosage": "قرص كل 8 ساعات", "duration": "5 أيام"},
            {"product_name": "Augmentin 1g", "quantity": 2, "dosage": "قرص كل 12 ساعة", "duration": "7 أيام"},
            {"product_name": "Paracetamol 500", "quantity": 1, "dosage": "قرص عند الحاجة كل 6 ساعات", "duration": "5 أيام"},
        ],
    },
    # 2. التهاب حلق
    {
        "patient_name": "فاطمة حسن إبراهيم",
        "patient_phone": "01098765432",
        "doctor_name": "د. سارة أحمد",
        "notes": "التهاب حاد في اللوزتين مع صعوبة في البلع",
        "items": [
            {"product_name": "Augmentin 1g", "quantity": 2, "dosage": "قرص كل 12 ساعة", "duration": "7 أيام"},
            {"product_name": "Brufen 400", "quantity": 1, "dosage": "قرص كل 8 ساعات بعد الأكل", "duration": "5 أيام"},
            {"product_name": "Betadine Solution", "quantity": 1, "dosage": "غرغرة 3 مرات يوميا", "duration": "7 أيام"},
        ],
    },
    # 3. ضغط عالي
    {
        "patient_name": "عبدالله محمود عبدالعزيز",
        "patient_phone": "01234567890",
        "doctor_name": "د. خالد حسين",
        "notes": "مريض ضغط مرتفع مزمن - متابعة شهرية",
        "items": [
            {"product_name": "Concor 5", "quantity": 3, "dosage": "قرص واحد يوميا صباحا", "duration": "شهر"},
            {"product_name": "Tritace 5", "quantity": 3, "dosage": "قرص واحد يوميا", "duration": "شهر"},
            {"product_name": "Aspocid 75", "quantity": 3, "dosage": "قرص واحد يوميا بعد الغداء", "duration": "شهر"},
        ],
    },
    # 4. سكر
    {
        "patient_name": "سعاد علي مصطفى",
        "patient_phone": "01156789012",
        "doctor_name": "د. هشام فاروق",
        "notes": "مريضة سكر من النوع الثاني - السكر التراكمي 8.5",
        "items": [
            {"product_name": "Glucophage 1000", "quantity": 3, "dosage": "قرص بعد الفطار وقرص بعد العشاء", "duration": "شهر"},
            {"product_name": "Amaryl 2", "quantity": 3, "dosage": "قرص واحد قبل الفطار", "duration": "شهر"},
            {"product_name": "Diamicron MR 60", "quantity": 3, "dosage": "قرص واحد قبل الفطار", "duration": "شهر"},
        ],
    },
    # 5. ألم مفاصل
    {
        "patient_name": "حسين عبدالحميد رضوان",
        "patient_phone": "01067891234",
        "doctor_name": "د. عمرو سعيد",
        "notes": "ألم شديد في الركبتين مع تورم - خشونة مفاصل",
        "items": [
            {"product_name": "Cataflam 50", "quantity": 2, "dosage": "قرص كل 8 ساعات بعد الأكل", "duration": "7 أيام"},
            {"product_name": "Myolgin", "quantity": 1, "dosage": "قرص كل 8 ساعات", "duration": "7 أيام"},
            {"product_name": "Voltaren Gel", "quantity": 1, "dosage": "دهان موضعي 3 مرات يوميا", "duration": "10 أيام"},
        ],
    },
    # 6. حساسية جلدية
    {
        "patient_name": "نورا عادل كمال",
        "patient_phone": "01189012345",
        "doctor_name": "د. رانيا محمود",
        "notes": "حساسية جلدية شديدة مع حكة واحمرار في الذراعين",
        "items": [
            {"product_name": "Telfast 180", "quantity": 1, "dosage": "قرص واحد يوميا مساءً", "duration": "10 أيام"},
            {"product_name": "Fucicort Cream", "quantity": 1, "dosage": "دهان موضعي مرتين يوميا", "duration": "7 أيام"},
        ],
    },
    # 7. التهاب معدة
    {
        "patient_name": "ياسر إبراهيم حسن",
        "patient_phone": "01201234567",
        "doctor_name": "د. أمين عبدالله",
        "notes": "التهاب في المعدة مع غثيان وقيء متكرر",
        "items": [
            {"product_name": "Nexium 40", "quantity": 2, "dosage": "قرص واحد يوميا قبل الفطار بنصف ساعة", "duration": "14 يوم"},
            {"product_name": "Antinal 200", "quantity": 1, "dosage": "كبسولة كل 8 ساعات", "duration": "5 أيام"},
            {"product_name": "Motilium 10", "quantity": 1, "dosage": "قرص قبل الأكل 3 مرات يوميا", "duration": "7 أيام"},
        ],
    },
    # 8. أزمة صدرية
    {
        "patient_name": "مصطفى كمال الدين",
        "patient_phone": "01012345678",
        "doctor_name": "د. طارق عبدالفتاح",
        "notes": "مريض ربو شعبي مزمن - ضيق تنفس متكرر خاصة أثناء الليل",
        "items": [
            {"product_name": "Ventolin Inhaler", "quantity": 1, "dosage": "بختين عند الحاجة", "duration": "شهر"},
            {"product_name": "Symbicort Turbuhaler", "quantity": 1, "dosage": "بختين مرتين يوميا", "duration": "شهر"},
            {"product_name": "Singulair 10", "quantity": 3, "dosage": "قرص واحد يوميا مساءً", "duration": "شهر"},
        ],
    },
    # 9. التهاب عيون
    {
        "patient_name": "منى سمير عبدالرازق",
        "patient_phone": "01145678901",
        "doctor_name": "د. حسام الشافعي",
        "notes": "التهاب في العين اليمنى مع احمرار وإفرازات",
        "items": [
            {"product_name": "Tobradex Eye Drops", "quantity": 1, "dosage": "نقطتين في العين المصابة 4 مرات يوميا", "duration": "7 أيام"},
            {"product_name": "Tears Naturale", "quantity": 1, "dosage": "نقطتين في العينين 4 مرات يوميا", "duration": "14 يوم"},
        ],
    },
    # 10. صداع نصفي
    {
        "patient_name": "هدى عبدالناصر محمد",
        "patient_phone": "01078901234",
        "doctor_name": "د. ياسمين حسن",
        "notes": "صداع نصفي شديد متكرر مع حساسية للضوء",
        "items": [
            {"product_name": "Brufen 400", "quantity": 1, "dosage": "قرص كل 8 ساعات بعد الأكل", "duration": "5 أيام"},
            {"product_name": "Myolgin", "quantity": 1, "dosage": "قرص كل 8 ساعات", "duration": "5 أيام"},
        ],
    },
    # 11. التهاب أذن
    {
        "patient_name": "كريم وليد حسين",
        "patient_phone": "01190123456",
        "doctor_name": "د. نادر فؤاد",
        "notes": "التهاب حاد في الأذن الوسطى مع ألم شديد",
        "items": [
            {"product_name": "Augmentin 1g", "quantity": 2, "dosage": "قرص كل 12 ساعة", "duration": "10 أيام"},
            {"product_name": "Brufen 400", "quantity": 1, "dosage": "قرص كل 8 ساعات بعد الأكل", "duration": "5 أيام"},
        ],
    },
    # 12. حالة طفل (حرارة + كحة)
    {
        "patient_name": "يوسف أحمد عبدالعال",
        "patient_phone": "01223456789",
        "doctor_name": "د. مها عبدالمنعم",
        "notes": "طفل عمره 4 سنوات - حرارة مرتفعة مع كحة شديدة ورشح",
        "items": [
            {"product_name": "Calpol Syrup", "quantity": 1, "dosage": "5 مل كل 6 ساعات عند الحرارة", "duration": "5 أيام"},
            {"product_name": "Prospan Syrup", "quantity": 1, "dosage": "2.5 مل 3 مرات يوميا", "duration": "7 أيام"},
            {"product_name": "Amoxil Syrup 250", "quantity": 1, "dosage": "5 مل كل 8 ساعات", "duration": "7 أيام"},
        ],
    },
    # 13. ألم أسنان
    {
        "patient_name": "رامي جمال عبدالحليم",
        "patient_phone": "01056789012",
        "doctor_name": "د. شريف سامي",
        "notes": "خراج في الضرس السفلي مع تورم شديد في الخد",
        "items": [
            {"product_name": "Cataflam 50", "quantity": 1, "dosage": "قرص كل 8 ساعات بعد الأكل", "duration": "5 أيام"},
            {"product_name": "Flagyl 500", "quantity": 1, "dosage": "قرص كل 8 ساعات", "duration": "7 أيام"},
            {"product_name": "Augmentin 1g", "quantity": 2, "dosage": "قرص كل 12 ساعة", "duration": "7 أيام"},
        ],
    },
    # 14. قلق واكتئاب
    {
        "patient_name": "سامية عبدالرحيم طه",
        "patient_phone": "01167890123",
        "doctor_name": "د. وائل إسماعيل",
        "notes": "حالة قلق واكتئاب متوسط - أرق مزمن وتوتر عصبي",
        "items": [
            {"product_name": "Cipralex 10", "quantity": 3, "dosage": "قرص واحد يوميا صباحا", "duration": "شهر"},
            {"product_name": "Dogmatil 50", "quantity": 3, "dosage": "قرص واحد يوميا", "duration": "شهر"},
        ],
    },
    # 15. قلب وكوليسترول
    {
        "patient_name": "محمود فتحي السعيد",
        "patient_phone": "01234567891",
        "doctor_name": "د. أشرف زكي",
        "notes": "مريض قلب - دعامة منذ سنتين - كوليسترول مرتفع",
        "items": [
            {"product_name": "Plavix 75", "quantity": 3, "dosage": "قرص واحد يوميا", "duration": "شهر"},
            {"product_name": "Concor 5", "quantity": 3, "dosage": "قرص واحد يوميا صباحا", "duration": "شهر"},
            {"product_name": "Crestor 10", "quantity": 3, "dosage": "قرص واحد يوميا مساءً", "duration": "شهر"},
        ],
    },
    # 16. التهاب مسالك بولية
    {
        "patient_name": "إيمان حسن عبدالغفار",
        "patient_phone": "01089012345",
        "doctor_name": "د. محمد نبيل",
        "notes": "التهاب حاد في المسالك البولية مع حرقان شديد",
        "items": [
            {"product_name": "Cipro 500", "quantity": 2, "dosage": "قرص كل 12 ساعة", "duration": "7 أيام"},
            {"product_name": "Brufen 400", "quantity": 1, "dosage": "قرص كل 8 ساعات بعد الأكل", "duration": "5 أيام"},
        ],
    },
    # 17. نقص فيتامينات
    {
        "patient_name": "دينا مصطفى كامل",
        "patient_phone": "01178901234",
        "doctor_name": "د. سلوى أحمد",
        "notes": "إرهاق مزمن ونقص في فيتامين د والحديد",
        "items": [
            {"product_name": "Centrum Silver", "quantity": 1, "dosage": "قرص واحد يوميا بعد الأكل", "duration": "شهر"},
            {"product_name": "Omega 3 Plus", "quantity": 1, "dosage": "كبسولة واحدة يوميا بعد الأكل", "duration": "شهر"},
            {"product_name": "Vidrop", "quantity": 1, "dosage": "15 نقطة أسبوعيا", "duration": "شهرين"},
        ],
    },
    # 18. إسهال شديد
    {
        "patient_name": "عمر طارق عبدالوهاب",
        "patient_phone": "01245678901",
        "doctor_name": "د. ريم عبدالقادر",
        "notes": "إسهال شديد منذ يومين مع جفاف - تسمم غذائي",
        "items": [
            {"product_name": "Antinal 200", "quantity": 1, "dosage": "كبسولة كل 8 ساعات", "duration": "5 أيام"},
            {"product_name": "Pedialyte Solution", "quantity": 5, "dosage": "كيس على لتر ماء - يشرب على مدار اليوم", "duration": "3 أيام"},
            {"product_name": "Lactulose", "quantity": 1, "dosage": "ملعقة كبيرة عند الحاجة", "duration": "5 أيام"},
        ],
    },
    # 19. حموضة مزمنة
    {
        "patient_name": "أمل رشدي حسن",
        "patient_phone": "01023456789",
        "doctor_name": "د. جمال عبدالناصر",
        "notes": "حموضة مزمنة وارتجاع في المريء منذ فترة طويلة",
        "items": [
            {"product_name": "Nexium 40", "quantity": 2, "dosage": "قرص واحد يوميا قبل الفطار بنصف ساعة", "duration": "شهر"},
            {"product_name": "Gaviscon Advance", "quantity": 1, "dosage": "ملعقة كبيرة بعد الأكل وقبل النوم", "duration": "14 يوم"},
        ],
    },
    # 20. ألم أعصاب
    {
        "patient_name": "سمير عبدالحكيم شاهين",
        "patient_phone": "01156781234",
        "doctor_name": "د. أحمد الشرقاوي",
        "notes": "ألم أعصاب مزمن في القدمين - اعتلال أعصاب طرفية",
        "items": [
            {"product_name": "Lyrica 150", "quantity": 3, "dosage": "كبسولة كل 12 ساعة", "duration": "شهر"},
            {"product_name": "Tegretol 200", "quantity": 3, "dosage": "قرص كل 12 ساعة", "duration": "شهر"},
            {"product_name": "Neurobion Forte", "quantity": 2, "dosage": "قرص يوميا بعد الأكل", "duration": "شهر"},
        ],
    },
]
