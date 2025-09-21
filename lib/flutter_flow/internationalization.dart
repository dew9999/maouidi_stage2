import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'ar', 'fr'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? arText = '',
    String? frText = '',
  }) =>
      [enText, arText, frText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // WelcomeScreen
  {
    'zuf2lagf': {
      'en': 'Welcome!',
      'ar': 'مرحباً!',
      'fr': 'Bienvenue!',
    },
    '2qjevbjl': {
      'en':
          'Thanks for joining! Access or create your account below, and get started on your journey!',
      'ar': 'شكرًا لانضمامك! سجّل دخولك أو أنشئ حسابك أدناه، وابدأ رحلتك!',
      'fr':
          'Merci de votre inscription ! Créez votre compte ci-dessous et commencez votre aventure !',
    },
    '68x5i214': {
      'en': 'Sign Up',
      'ar': 'إنشاء حساب',
      'fr': 'S\'inscrire',
    },
    'oerhp1hv': {
      'en': 'Log In',
      'ar': 'تسجيل الدخول',
      'fr': 'Se connecter',
    },
    'gwikz03c': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // Login
  {
    'elr6im80': {
      'en': 'Sign In',
      'ar': 'تسجيل الدخول',
      'fr': 'Se connecter',
    },
    'bw1u9riq': {
      'en': 'Use the account below to sign in.',
      'ar': 'استخدم الحساب أدناه لتسجيل الدخول.',
      'fr': 'Utilisez le compte ci-dessous pour vous connecter.',
    },
    'wjgfytq8': {
      'en': 'Email',
      'ar': 'بريد إلكتروني',
      'fr': 'E-mail',
    },
    'nxmkoh8g': {
      'en': 'Password',
      'ar': 'كلمة المرور',
      'fr': 'Mot de passe',
    },
    'j50kiywl': {
      'en': 'Sign In',
      'ar': 'تسجيل الدخول',
      'fr': 'Se connecter',
    },
    '0simneyn': {
      'en': 'Forgot Password',
      'ar': 'هل نسيت كلمة السر ؟',
      'fr': 'Mot de passe oublié ?',
    },
    'wx00cofk': {
      'en': 'Or sign up with',
      'ar': 'أو قم بالتسجيل مع',
      'fr': 'Ou inscrivez-vous avec',
    },
    'tg5bsars': {
      'en': 'Continue with Google',
      'ar': 'متابعة مع جوجل',
      'fr': 'Continuer avec Google',
    },
    'hrvpvy6b': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // HomePage
  {
    'zwhxx1yq': {
      'en': 'Search by name...',
      'ar': 'البحث حسب الاسم...',
      'fr': 'Rechercher par nom...',
    },
    't7w8u2b4': {
      'en': 'Doctors',
      'ar': 'الأطباء',
      'fr': 'Médecins',
    },
    'fvarzh30': {
      'en': 'Clinics',
      'ar': 'العيادات',
      'fr': 'Cliniques',
    },
    'vzmuomic': {
      'en': 'Nurses',
      'ar': 'الممرضات',
      'fr': 'Infirmières',
    },
    '22avau5o': {
      'en': 'Charities',
      'ar': 'الجمعيات الخيرية',
      'fr': 'Organismes de bienfaisance',
    },
    'sh600y77': {
      'en': 'Most Successful With Maouidi',
      'ar': 'الأكثر نجاحا مع موعدي',
      'fr': 'Le plus réussi avec Maouidi',
    },
    'wdwcwjyw': {
      'en': 'Maouidi',
      'ar': 'موعدي',
      'fr': 'Maouidi',
    },
    '20ji95h5': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // Create
  {
    'za064viu': {
      'en': 'Welcome to our Maouidi',
      'ar': 'مرحباً بكم في موعدي!',
      'fr': 'Bienvenue sur notre maouidi ',
    },
    '849zhxnf': {
      'en': 'First Name',
      'ar': 'الاسم الأول',
      'fr': 'Prénom',
    },
    'nzslchkp': {
      'en': 'Last Name',
      'ar': 'اسم العائلة',
      'fr': 'Nom de famille',
    },
    'mwny79n8': {
      'en': 'Email Address',
      'ar': 'عنوان البريد الإلكتروني',
      'fr': 'Adresse email',
    },
    'rfkbeomw': {
      'en': 'Password',
      'ar': 'كلمة المرور',
      'fr': 'Mot de passe',
    },
    'o1s0s1ma': {
      'en': 'Confirm Password',
      'ar': 'تأكيد كلمة المرور',
      'fr': 'Confirmez le mot de passe',
    },
    'hr7g0yzr': {
      'en': 'Create Account',
      'ar': 'إنشاء حساب',
      'fr': 'Créer un compte',
    },
    'aszmkszw': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // ForgotPassword
  {
    'uhtykqxj': {
      'en': 'Forgot Password ?',
      'ar': 'هل نسيت كلمة السر ؟',
      'fr': 'Mot de passe oublié ?',
    },
    'amfoac12': {
      'en': 'We will send you a reset link.',
      'ar': 'سوف نرسل لك رابط إعادة الضبط.',
      'fr': 'Nous vous enverrons un lien de réinitialisation.',
    },
    '67zxss38': {
      'en': 'Email Address',
      'ar': 'عنوان البريد الإلكتروني',
      'fr': 'Adresse email',
    },
    '73m8o8df': {
      'en': 'Send Link',
      'ar': 'إرسال الرابط',
      'fr': 'Envoyer le lien',
    },
    'xxcewudt': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // user_profile
  {
    'fy0elrsd': {
      'en': 'First Name',
      'ar': 'الاسم الأول',
      'fr': 'Prénom',
    },
    'vosm0bwg': {
      'en': 'Last Name',
      'ar': 'اسم العائلة',
      'fr': 'Nom de famille',
    },
    'eqq0jrej': {
      'en': 'Your City',
      'ar': 'مدينتك',
      'fr': 'Votre ville',
    },
    'cwmwf25u': {
      'en': 'State',
      'ar': 'ولاية',
      'fr': 'Wilaya',
    },
    'z5beizd1': {
      'en': 'Select State',
      'ar': 'اختر الولاية',
      'fr': 'Sélectionnez l\'wilaya',
    },
    'm2alpr46': {
      'en': 'State',
      'ar': 'ولاية',
      'fr': 'Wilaya',
    },
    'apaf84l8': {
      'en': 'Adrar',
      'ar': 'أدرار',
      'fr': 'Adrar',
    },
    'ntnczbdg': {
      'en': 'Chlef',
      'ar': 'الشلف',
      'fr': 'Chlef',
    },
    'mxmzs0a3': {
      'en': 'Laghouat',
      'ar': 'الأغواط',
      'fr': 'Laghouat',
    },
    'fouv3w2q': {
      'en': 'Oum El Bouaghi',
      'ar': 'أم البواقي',
      'fr': 'Oum El Bouaghi',
    },
    'bvn872zt': {
      'en': 'Batna',
      'ar': 'باتنة',
      'fr': 'Batna',
    },
    'cb14i4oi': {
      'en': 'Béjaïa',
      'ar': 'بجاية',
      'fr': 'Bejaia',
    },
    'ellfgujq': {
      'en': 'Biskra',
      'ar': 'بسكرة',
      'fr': 'Biskra',
    },
    '34ys82ze': {
      'en': 'Béchar',
      'ar': 'بشار',
      'fr': 'Bechar',
    },
    '48s7y9hv': {
      'en': 'Blida',
      'ar': 'البليدة',
      'fr': 'Blida',
    },
    'v01g7zjn': {
      'en': 'Bouira',
      'ar': 'بويرة',
      'fr': 'Bouira',
    },
    'xnios9o7': {
      'en': 'Tamanrasset',
      'ar': 'تمنراست',
      'fr': 'Tamanrasset',
    },
    '271h7gjg': {
      'en': 'Tébessa',
      'ar': 'تبسة',
      'fr': 'Tebessa',
    },
    '5pd3cks6': {
      'en': 'Tlemcen',
      'ar': 'تلمسان',
      'fr': 'Tlemcen',
    },
    'm35h964i': {
      'en': 'Tiaret',
      'ar': 'تيارت',
      'fr': 'Tiaret',
    },
    '5s1yrrgz': {
      'en': 'Tizi Ouzou',
      'ar': 'تيزي وزو',
      'fr': 'Tizi-Ouzou',
    },
    'jwv7603y': {
      'en': 'Alger',
      'ar': 'الجزائر',
      'fr': 'Alger',
    },
    'u7lv97x0': {
      'en': 'Djelfa',
      'ar': 'الجلفة',
      'fr': 'Djelfa',
    },
    'g6g6pyix': {
      'en': 'Jijel',
      'ar': 'جيجل',
      'fr': 'Jijel',
    },
    '8i86cecp': {
      'en': 'Sétif',
      'ar': 'سطيف',
      'fr': 'Sétif',
    },
    '75jt5cri': {
      'en': 'Saïda',
      'ar': 'سعيدة',
      'fr': 'Saida',
    },
    'm0w6gkgt': {
      'en': ' Skikda',
      'ar': 'سكيكدة',
      'fr': 'Skikda',
    },
    '39wt5r7y': {
      'en': 'Sidi Bel Abbès',
      'ar': 'سيدي بلعباس',
      'fr': 'Sidi Bel Abbès',
    },
    '4v5gs4j9': {
      'en': 'Annaba',
      'ar': 'عنابة',
      'fr': 'Annaba',
    },
    '5vrlknjp': {
      'en': 'Guelma',
      'ar': 'قالمة',
      'fr': 'Guelma',
    },
    'gtb20ch0': {
      'en': 'Constantine',
      'ar': 'قسنطينة',
      'fr': 'Constantine',
    },
    'oetg9pes': {
      'en': 'Médéa',
      'ar': 'مدية',
      'fr': 'Medea',
    },
    'bojso2kc': {
      'en': 'Mostaganem',
      'ar': 'مستغانم',
      'fr': 'Mostaganem',
    },
    '5xb2n0wu': {
      'en': 'M\'Sila',
      'ar': 'مسيلة',
      'fr': 'M\'Sila',
    },
    'qdjswkdd': {
      'en': 'Mascare',
      'ar': 'معسكر',
      'fr': 'Mascare',
    },
    'wlp053g9': {
      'en': 'Ouargla ',
      'ar': 'ورقلة',
      'fr': 'Ouargla',
    },
    '3zwjps6w': {
      'en': 'Oran',
      'ar': 'وهران',
      'fr': 'Oran',
    },
    '5chciytd': {
      'en': 'El Bayadh',
      'ar': 'البيض',
      'fr': 'El Bayadh',
    },
    '14g5bg9k': {
      'en': 'Illizi ',
      'ar': 'إليزي',
      'fr': 'Illizi',
    },
    '1xudq5j7': {
      'en': 'Bordj Bou Arreridj',
      'ar': 'برج بوعريريج',
      'fr': 'Bordj Bou Arreridj',
    },
    'ocxj8qv5': {
      'en': 'Boumerdès',
      'ar': 'بومرداس',
      'fr': 'Boumerdès',
    },
    '6up86wqq': {
      'en': 'El Tarf',
      'ar': 'الطارف',
      'fr': 'El Tarf',
    },
    'r99bbz56': {
      'en': 'Tindouf',
      'ar': 'تندوف',
      'fr': 'Tindouf',
    },
    'dm1dx74f': {
      'en': 'Tissemsilt',
      'ar': 'تيسمسيلت',
      'fr': 'Tissemsilt',
    },
    'rmyvnt3d': {
      'en': 'Oued souf',
      'ar': 'واد سوف',
      'fr': 'Oued souf',
    },
    'vhq0h5ap': {
      'en': 'Khenchela',
      'ar': 'خنشلة',
      'fr': 'Khenchela',
    },
    'pwadd8m5': {
      'en': ' Souk Ahras',
      'ar': 'سوق أهراس',
      'fr': 'Souk Ahras',
    },
    't1vbc00s': {
      'en': 'Tipaza',
      'ar': 'تيبازة',
      'fr': 'Tipaza',
    },
    '6xzzb2u9': {
      'en': 'Mila',
      'ar': 'ميلة',
      'fr': 'Mila',
    },
    '44upgi4e': {
      'en': 'Aïn Defla',
      'ar': 'عين الدفلى',
      'fr': 'Aïn Defla',
    },
    '2l5wyetr': {
      'en': 'Naâma',
      'ar': 'نعامة',
      'fr': 'Naâma',
    },
    '4xme2xmb': {
      'en': 'Aïn Témouchent',
      'ar': 'عين تموشنت',
      'fr': 'Ain Témouchent',
    },
    'giweyn9p': {
      'en': 'Ghardaïa ',
      'ar': 'غرداية',
      'fr': 'Ghardaia',
    },
    'hye1y6wv': {
      'en': 'Relizane',
      'ar': 'غليزان',
      'fr': 'Relizane',
    },
    '5hjy89n5': {
      'en': 'Timimoun',
      'ar': 'تيميمون',
      'fr': 'Timimoun',
    },
    'di3c5ajb': {
      'en': 'Bordj Badji Mokhtar ',
      'ar': 'برج باجي مختار',
      'fr': 'Bordj Badji Mokhtar',
    },
    'k6eoy4n8': {
      'en': 'Ouled Djellal',
      'ar': 'أولاد جلال',
      'fr': 'Ouled Djellal',
    },
    'myfick3q': {
      'en': 'Béni Abbès',
      'ar': 'بني عباس',
      'fr': 'Beni Abbes',
    },
    '94l5bvac': {
      'en': 'In Salah',
      'ar': 'في صلاح',
      'fr': 'Dans Salah',
    },
    'n28gf94q': {
      'en': 'AIn Guezzam ',
      'ar': 'عين قزام',
      'fr': 'Ain Guezzam',
    },
    'nainpsx8': {
      'en': 'Touggourt',
      'ar': 'تقرت',
      'fr': 'Touggourt',
    },
    '9r7wbb04': {
      'en': 'Djanet',
      'ar': 'جانت',
      'fr': 'Djanet',
    },
    'd3paga07': {
      'en': 'El M\'Ghair ',
      'ar': 'المغير',
      'fr': 'El M\'Ghair',
    },
    '7eiuuybp': {
      'en': 'El Meniaa ',
      'ar': 'المنيعة',
      'fr': 'El Meniaa',
    },
    'wj292q10': {
      'en': 'Phone Number',
      'ar': 'رقم الهاتف',
      'fr': 'Numéro de téléphone',
    },
    'apt4pzzn': {
      'en': 'Date of Birth',
      'ar': 'تاريخ الميلاد',
      'fr': 'Date de naissance',
    },
    '8io02lhc': {
      'en': 'Gender',
      'ar': 'جنس',
      'fr': 'Sexe',
    },
    'u2ud5wxa': {
      'en': 'Search...',
      'ar': 'يبحث...',
      'fr': 'Recherche...',
    },
    'bcimzbuc': {
      'en': 'Male',
      'ar': 'ذكر',
      'fr': 'Mâle',
    },
    'pz3gjudb': {
      'en': 'Female',
      'ar': 'أنثى',
      'fr': 'Femelle',
    },
    'f44yu971': {
      'en': 'Save Changes',
      'ar': 'حفظ التغييرات',
      'fr': 'Enregistrer les modifications',
    },
    'cccdi4d4': {
      'en': 'Create your Profile',
      'ar': 'إنشاء ملفك الشخصي',
      'fr': 'Créez votre profil',
    },
  },
  // PartnerListPage
  {
    '6i37l4q8': {
      'en': 'Maouidi',
      'ar': 'موعدي',
      'fr': 'Maouidi',
    },
    'l605fj15': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // PartnerProfilePage
  {
    'gcyp6yu3': {
      'en': 'Hello World',
      'ar': 'مرحبا بالعالم',
      'fr': 'Bonjour le monde',
    },
    '9qizc746': {
      'en': 'Hello World',
      'ar': 'مرحبا بالعالم',
      'fr': 'Bonjour le monde',
    },
    'rhf4eqep': {
      'en': 'Book Appointment',
      'ar': 'حجز موعد',
      'fr': 'Prendre rendez-vous',
    },
    '9lram0mf': {
      'en': 'Page Title',
      'ar': 'موعدي',
      'fr': 'Maouidi',
    },
    '57cmvb76': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // BookingPage
  {
    'lhcwyyjy': {
      'en': 'Maouidi',
      'ar': 'موعدي',
      'fr': 'Maouidi',
    },
    'psy0scpf': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // PatientDashboard
  {
    'kxjy3dtr': {
      'en': 'Upcoming',
      'ar': 'القادمة',
      'fr': 'Prochain',
    },
    'q9yem3kv': {
      'en': 'History',
      'ar': 'تاريخ',
      'fr': 'Histoire',
    },
    'c7lkhd38': {
      'en': 'Maouidi',
      'ar': 'موعدي',
      'fr': 'Maouidi',
    },
    'tpje9xqm': {
      'en': 'appointments',
      'ar': 'المواعيد',
      'fr': 'rendez-vous',
    },
  },
  // partnerDashboardPage
  {
    '73waffku': {
      'en': 'Pending',
      'ar': 'قيد الانتظار',
      'fr': 'En attente',
    },
    'zfaafvpw': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    'wytmflzr': {
      'en': 'Completed',
      'ar': 'مكتمل',
      'fr': 'Complété',
    },
    '6izkvqj3': {
      'en': 'Canceled',
      'ar': 'ملغى',
      'fr': 'Annulé',
    },
    'ehx71afh': {
      'en': 'Maouidi',
      'ar': 'موعدي',
      'fr': 'Maouidi',
    },
    's8cxbprt': {
      'en': 'Home',
      'ar': 'الرئيسة',
      'fr': 'Accueille',
    },
  },
  // pendingggg
  {
    '60051zrv': {
      'en': 'Michael Chen',
      'ar': 'مايكل تشين',
      'fr': 'Michael Chen',
    },
    '6u756uqy': {
      'en': 'Pending',
      'ar': 'قيد الانتظار',
      'fr': 'En attente',
    },
    'crbm9749': {
      'en': '2:15 PM',
      'ar': '2:15 مساءً',
      'fr': '14h15',
    },
    'pzv8z4vp': {
      'en': 'Pending',
      'ar': 'قيد الانتظار',
      'fr': 'En attente',
    },
    '1buath76': {
      'en': 'Accept',
      'ar': 'قبول',
      'fr': 'Accepter',
    },
    '3was2jnu': {
      'en': 'Decline',
      'ar': 'رفض',
      'fr': 'Réfuser',
    },
  },
  // confirmeddddd
  {
    'y3fw9oe1': {
      'en': 'Sarah Johnson',
      'ar': 'سارة جونسون',
      'fr': 'Sarah Johnson',
    },
    'aynsj1wm': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    '66cb3nvh': {
      'en': '10:30 AM',
      'ar': '10:30 صباحًا',
      'fr': '10h30',
    },
    'diyjjby0': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
  },
  // completed
  {
    'kgyipfus': {
      'en': 'Emma Wilson',
      'ar': 'إيما ويلسون',
      'fr': 'Emma Wilson',
    },
    'l9j97gpj': {
      'en': 'Completed',
      'ar': 'مكتمل',
      'fr': 'Complété',
    },
    'f38a2ded': {
      'en': '4:00 PM',
      'ar': 'الساعة 4:00 مساءً',
      'fr': '16h00',
    },
    'xxzt5c3y': {
      'en': 'Completed',
      'ar': 'مكتمل',
      'fr': 'Complété',
    },
  },
  // canceled
  {
    'r3r9bttx': {
      'en': 'Sarah Johnson',
      'ar': 'سارة جونسون',
      'fr': 'Sarah Johnson',
    },
    'zxitu026': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    'rnv7wmit': {
      'en': '10:30 AM',
      'ar': '10:30 صباحًا',
      'fr': '10h30',
    },
    'cvec8n9o': {
      'en': 'Canceled',
      'ar': 'ملغى',
      'fr': 'Annulé',
    },
  },
  // roow
  {
    'j3vk98bd': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    'booip0g4': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    'jxwlj9wn': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    '7w2jdkis': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
  },
  // canceledCopy
  {
    '20hhttuv': {
      'en': 'Sarah Johnson',
      'ar': 'سارة جونسون',
      'fr': 'Sarah Johnson',
    },
    '0xd1dl4n': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    'ovj494wg': {
      'en': '10:30 AM',
      'ar': '10:30 صباحًا',
      'fr': '10h30',
    },
    '1rjx3q4r': {
      'en': 'Canceled',
      'ar': 'ملغى',
      'fr': 'Annulé',
    },
  },
  // confirmedddddCopy
  {
    'tdljov4n': {
      'en': 'Sarah Johnson',
      'ar': 'سارة جونسون',
      'fr': 'Sarah Johnson',
    },
    'r8i6g7hn': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    '1lj44kt2': {
      'en': '10:30 AM',
      'ar': '10:30 صباحًا',
      'fr': '10h30',
    },
    'lzszge29': {
      'en': 'Confirmed',
      'ar': 'مؤكد',
      'fr': 'Confirmé',
    },
    'u87ghkya': {
      'en': 'Cancel',
      'ar': '',
      'fr': '',
    },
  },
  // pendinggggCopy2
  {
    'k9xjrpie': {
      'en': 'Michael Chen',
      'ar': 'مايكل تشين',
      'fr': 'Michael Chen',
    },
    '3vx9ncgt': {
      'en': 'Pending',
      'ar': 'قيد الانتظار',
      'fr': 'En attente',
    },
    'eom1hsps': {
      'en': '2:15 PM',
      'ar': '2:15 مساءً',
      'fr': '14h15',
    },
    '1ael9pte': {
      'en': 'Pending',
      'ar': 'قيد الانتظار',
      'fr': 'En attente',
    },
    'nyjvzba7': {
      'en': 'Decline',
      'ar': 'رفض',
      'fr': 'Réfuser',
    },
  },
  // completedCopy
  {
    't2t9xlpl': {
      'en': 'Emma Wilson',
      'ar': 'إيما ويلسون',
      'fr': 'Emma Wilson',
    },
    'bqw87owz': {
      'en': 'Completed',
      'ar': 'مكتمل',
      'fr': 'Complété',
    },
    'gvkuvreb': {
      'en': '4:00 PM',
      'ar': 'الساعة 4:00 مساءً',
      'fr': '16h00',
    },
    'p7l2ojqb': {
      'en': 'Completed',
      'ar': 'مكتمل',
      'fr': 'Complété',
    },
  },
  // perfectcardforthepatientdashboard
  {
    'rsnny69i': {
      'en': 'Cancel',
      'ar': 'يلغي',
      'fr': 'Annuler',
    },
  },
  // Miscellaneous
  {
    'ruicvdi4': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'zhk5ynls': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'j6jjxgd5': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    '1rjsnodz': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'gss4jysh': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    '7ti3scrb': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    's6oofcno': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'gxwhv9k7': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'dx3013rr': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'fdt5fp6a': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    '8gaumetq': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    '0xw7d8qf': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'b0wcyjn3': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'rwjcbkay': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'qhuvqokg': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    '363gqde1': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'l5mo5o20': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    '4cq613bh': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'qp9ynx3h': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'ru9f0kyi': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'luvq33bo': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'xeor3hjm': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    '58g06nlp': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    'qyz0vfyd': {
      'en': '',
      'ar': '',
      'fr': '',
    },
    '7d4lnjf6': {
      'en': '',
      'ar': '',
      'fr': '',
    },
  },
].reduce((a, b) => a..addAll(b));
