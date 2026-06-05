# 🍻 Choperia 820 - Delivery App (Mobile)

O aplicativo oficial da **Choperia 820** (Orlândia - SP), desenvolvido em **Flutter** para modernizar o atendimento e oferecer a melhor experiência de cardápio digital, delivery e retirada aos clientes. Totalmente sincronizado em tempo real com o painel administrativo.

---

## ✨ Principais Funcionalidades

* 📱 **Cardápio Digital Dinâmico:** Navegação fluida por categorias (Porções,Couverts, Lanches). As fotos e os preços vêm direto do banco de dados na nuvem (sempre atualizados).
* 🛒 **Carrinho Inteligente:** Adição de produtos, controle de quantidade, cálculo automático de subtotal e taxas.
* 🔐 **Login Seguro com Google:** Sistema prático e seguro onde o cliente faz login com um clique usando a conta do Google via Firebase Auth.
* 🚴 **Acompanhamento de Pedidos:** Acompanhe o status do pedido (Preparando, Saiu para Entrega, Finalizado) com sincronização em tempo real.
* 🖼️ **Imagens em Cache Automático:** Todas as fotos do cardápio são otimizadas e cacheadas no dispositivo do usuário para não gastar dados móveis e carregar instantaneamente nas próximas vezes.
* 💬 **Atendimento Direto:** Integração via links diretos (WhatsApp/Telefone) para suporte rápido.

---

## 🛠️ Arquitetura e Tecnologias

Este projeto mobile segue padrões rígidos de mercado, utilizando as bibliotecas mais performáticas do ecossistema Dart/Flutter:

* **[Flutter & Dart](https://flutter.dev/):** Interface nativa, multiplataforma e de alta performance.
* **[Provider](https://pub.dev/packages/provider):** Gerenciamento de estado descentralizado (mantendo o Carrinho, Usuário e Pedidos rodando fluidamente por trás dos panos).
* **[Firebase Auth & Google Sign-In](https://firebase.google.com/):** Autenticação robusta para clientes, bloqueando pedidos fantasmas e garantindo a identidade.
* **[Cloud Firestore](https://firebase.google.com/docs/firestore):** Banco de dados NoSQL que avisa o app na mesma hora em que o restaurante altera um preço ou status de pedido no painel.
* **[Cached Network Image](https://pub.dev/packages/cached_network_image):** Motor inteligente de carregamento e salvamento offline das fotos do cardápio (vindas do Firebase Storage).


---

## 🔒 Segurança e Integração

O aplicativo funciona em conjunto com o Painel Administrativo. Devido às recentes atualizações de arquitetura:
- Os clientes só conseguem realizar pedidos se estiverem logados e autenticados pelo Google.
- O aplicativo apenas lê (Read-Only) o cardápio no banco de dados; nenhuma alteração de preços pode ser feita por clientes, blindando a integridade do restaurante contra fraudes.
- Imagens do cardápio agora são consumidas via internet direto do Storage oficial do Firebase, descartando a necessidade de atualizar o aplicativo na loja (Play Store/App Store) toda vez que a choperia adiciona uma foto nova.

---

## 🚀 Como executar o projeto localmente

### Pré-requisitos
* Ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) atualizado (versão 3.10+).
* Ter um Emulador (Android Studio / iOS Simulator) ou um celular físico com depuração USB ativa.

### Instalação

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/kauageorjuti/choperia-820-app.git
   cd choperia_820_app
