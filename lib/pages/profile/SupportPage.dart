import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  final ScrollController _scrollController = ScrollController();

  bool _isMenuOpen = false;
  int? _selectedCategoryIndex;

  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Bonjour voyageur ! 🌍\nJe suis l'assistant Atlas. Choisis une catégorie ci-dessous pour trouver ta réponse.",
      "isUser": false,
    }
  ];

  final List<Map<String, dynamic>> _supportData = [
    {
      "category": "Ma Commande en cours",
      "icon": Icons.delivery_dining,
      "questions": [
        {
          "q": "Où est mon livreur ?",
          "a": "Tu peux suivre ton livreur en temps réel sur la carte de la page 'Suivi'. Si l'icône ne bouge pas pendant plus de 5 minutes, il est peut-être coincé dans le trafic ou en train de garer son scooter."
        },
        {
          "q": "Le livreur est en retard",
          "a": "Nous sommes désolés pour ce délai. La circulation ou la météo peuvent parfois ralentir nos explorateurs. Si le retard dépasse 20 minutes par rapport à l'heure estimée, contacte-nous pour un geste commercial."
        },
        {
          "q": "Je veux annuler ma commande",
          "a": "Si le restaurant n'a pas encore commencé la préparation (statut 'Validée'), tu peux annuler sans frais. Si la préparation est lancée, des frais d'annulation s'appliqueront pour couvrir les ingrédients."
        },
        {
          "q": "Modifier mon adresse de livraison",
          "a": "Si le livreur n'est pas encore parti, appelle-le directement via l'icône téléphone sur l'écran de suivi. Sinon, contacte le support d'urgence."
        }
      ]
    },
    {
      "category": "Problème avec un plat",
      "icon": Icons.soup_kitchen,
      "questions": [
        {
          "q": "Il manque un article",
          "a": "Aïe, c'est frustrant ! Prends une photo de ton reçu et du contenu du sac. Va dans 'Historique' > 'Signaler un problème' et on te remboursera l'article manquant instantanément."
        },
        {
          "q": "Mon plat est arrivé froid",
          "a": "Ce n'est pas la qualité Atlas que nous visons. Assure-toi que le trajet n'était pas trop long. Si c'est anormal, signale-le nous pour obtenir un crédit sur ta prochaine commande."
        },
        {
          "q": "Erreur sur la commande",
          "a": "Tu as reçu une pizza au lieu d'un burger ? Oups ! Signale-le immédiatement avec une photo. Tu pourras garder le plat reçu et on te remboursera."
        },
        {
          "q": "Problème d'hygiène ou qualité",
          "a": "Nous prenons cela très au sérieux. Contacte immédiatement notre service qualité via le formulaire dédié avec des photos. Nous mènerons une enquête auprès du restaurant."
        }
      ]
    },
    {
      "category": "Paiement & Facturation",
      "icon": Icons.credit_card,
      "questions": [
        {
          "q": "Quels moyens de paiement acceptez-vous ?",
          "a": "Nous acceptons les cartes bancaires (Visa, Mastercard), Apple Pay, Google Pay ainsi que PayPal"
        },
        {
          "q": "Mon paiement a été refusé",
          "a": "Vérifie que ton plafond n'est pas atteint et que ta carte est valide. Parfois, supprimer et réenregistrer la carte résout le problème. Sinon, essaie PayPal."
        },
        {
          "q": "Où trouver ma facture ?",
          "a": "Toutes tes factures sont envoyées par email après la livraison. Tu peux aussi les retrouver dans Profil > Historique des commandes > Voir le reçu."
        },
        {
          "q": "J'ai un code promo",
          "a": "Super ! Tu peux l'ajouter au moment du paiement dans la case 'Ajouter un code promo'. Attention, ils ne sont pas cumulables avec les offres en cours."
        }
      ]
    },
    {
      "category": "Compte & Atlas Premium",
      "icon": Icons.diamond,
      "questions": [
        {
          "q": "Qu'est-ce que Atlas Premium ?",
          "a": "C'est notre pass voyageur ! Pour 9.99€/mois, tu as la livraison offerte en illimité sur toutes les commandes de plus de 15€ et des offres exclusives."
        },
        {
          "q": "Comment se désabonner ?",
          "a": "Tu es libre comme l'air. Va dans Profil > Atlas Premium > Gérer mon abonnement > Résilier. L'abonnement s'arrêtera à la fin de la période en cours."
        },
        {
          "q": "Modifier mon mot de passe",
          "a": "Rendez-vous dans Profil > Sécurité > Changer le mot de passe. Si tu l'as oublié, utilise l'option 'Mot de passe oublié' sur l'écran de connexion."
        },
        {
          "q": "Supprimer mon compte",
          "a": "Tu vas nous manquer ! Cette option irréversible se trouve tout en bas de la page Profil > Paramètres."
        }
      ]
    },
    {
      "category": "Application & Technique",
      "icon": Icons.phone_android,
      "questions": [
        {
          "q": "L'application est lente",
          "a": "Essaie de vider le cache de l'application dans les réglages de ton téléphone ou vérifie ta connexion internet. Une mise à jour est peut-être disponible sur le Store."
        },
        {
          "q": "Je ne reçois pas les notifications",
          "a": "Vérifie dans les réglages de ton téléphone que tu as autorisé Atlas à t'envoyer des notifications. C'est essentiel pour suivre ton livreur !"
        },
        {
          "q": "Signaler un bug",
          "a": "Merci de nous aider à nous améliorer ! Envoie une capture d'écran et une description du problème à tech@atlas-food.com."
        }
      ]
    },
    {
      "category": "À propos d'Atlas",
      "icon": Icons.public,
      "questions": [
        {
          "q": "C'est quoi le concept Atlas ?",
          "a": "Atlas, c'est le goût du voyage à domicile. Nous sélectionnons les meilleures spécialités du monde entier pour te les livrer en moins de 30 minutes."
        },
        {
          "q": "Recrutez-vous des livreurs ?",
          "a": "Oui, nous cherchons toujours des explorateurs ! Rends-toi sur notre site web section 'Devenir partenaire' pour postuler."
        },
        {
          "q": "Vos emballages sont-ils écologiques ?",
          "a": "Absolument. 95% de nos emballages sont en carton recyclé ou en matériaux biodégradables. Nous visons le 100% d'ici l'année prochaine."
        }
      ]
    }
  ];

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add({"text": text, "isUser": isUser});
      if (isUser) {
        _isMenuOpen = false;
        _selectedCategoryIndex = null;
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuestionTap(String question, String answer) async {
    _addMessage(question, true);
    await Future.delayed(const Duration(milliseconds: 600));
    _addMessage(answer, false);
  }

  @override
  Widget build(BuildContext context) {
    
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color assistantBubbleColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF5F5F5);
    final Color userBubbleColor = isDark ? yellowColor : Colors.black;
    final Color userTextColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: yellowColor, shape: BoxShape.circle),
              child: const Icon(Icons.headset_mic, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              "Atlas Support",
              style: GoogleFonts.lilitaOne(color: textColor, fontSize: 24),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isMenuOpen) setState(() => _isMenuOpen = false);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['isUser'];

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser ? userBubbleColor : assistantBubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                          bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                        ),
                        border: !isUser && isDark ? Border.all(color: Colors.white10) : null,
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: isUser ? userTextColor : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            height: _isMenuOpen ? 450 : 80,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: isDark ? const Border(top: BorderSide(color: Colors.white10)) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedCategoryIndex != null) {
                        _selectedCategoryIndex = null;
                      } else {
                        _isMenuOpen = !_isMenuOpen;
                      }
                    });
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                         if (_selectedCategoryIndex != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Icon(Icons.arrow_back, color: yellowColor),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _selectedCategoryIndex != null
                                  ? _supportData[_selectedCategoryIndex!]['category']
                                  : "Catégories d'aide",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              if (!_isMenuOpen)
                                Text(
                                  "Toucher pour voir les options",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white38 : Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_selectedCategoryIndex == null)
                        AnimatedRotation(
                          turns: _isMenuOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.keyboard_arrow_up, color: isDark ? yellowColor : Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: _selectedCategoryIndex == null
                    ? Column(
                        children: _supportData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => setState(() => _selectedCategoryIndex = index),
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white10 : Colors.white,
                                        shape: BoxShape.circle,
                                        border: isDark ? Border.all(color: yellowColor.withOpacity(0.3)) : null,
                                      ),
                                      child: Icon(category['icon'], size: 20, color: isDark ? yellowColor : Colors.black),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        category['category'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? Colors.white24 : Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Column(
                        children: (_supportData[_selectedCategoryIndex!]['questions'] as List).map((q) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _handleQuestionTap(q['q'], q['a']),
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: yellowColor.withOpacity(isDark ? 0.2 : 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: yellowColor.withOpacity(isDark ? 0.02 : 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4)
                                    )
                                  ]
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        q['q'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chat_bubble_outline, size: 16, color: yellowColor),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}