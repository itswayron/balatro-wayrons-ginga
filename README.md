# Wayron's Ginga

A Balatro mod that introduces innovative Jokers, a custom Deck with an energy reserve mechanism, and mod integrations (CardSleeves and JokerDisplay).

---

## 🃏 Jokers

| Joker | Rarity | Cost | Effect |
| :--- | :--- | :--- | :--- |
| **Card up the Sleeve**<br>*(Carta na Manga)* | Rare | $8 | Played cards also count as cards **held in hand**. |
| **Another One**<br>*(Tem Outra)* | Rare | $8 | Cards **held in hand** also count as **played cards**. **-1** hand size. |
| **Occultist**<br>*(Ocultista)* | Uncommon | $6 | When Blind is selected, **1 in 3** chance to create a **Spectral** card *(Must have room)*. |
| **Vibe Coder** | Uncommon | $5 | When Blind is selected, **1 in 2** chance to copy the ability of a **random Joker** for the entire Blind. |
| **Leftmost Zero**<br>*(0 à Esquerda)* | Uncommon | $5 | The **leftmost** Joker becomes **Negative**. *(Ignores Negative Jokers)*. |
| **Stack Overflow** | Legendary | $20 | All **retrigger** effects have a **3 in 4 (75%)** chance to **retrigger again** *(Includes retriggers from this Joker. Unaffected by dice)*. |

---

## 🔋 Decks

### **Battery Deck** *(Deck Bateria)*
* Surplus score from beaten Blinds charges your **Battery**.
* Max capacity is **2X the sum** of all Blinds in the current Ante.
* On the **final hand** of a Blind, automatically uses battery charge if needed to beat the Blind.
* **X1.5** base Blind size.

---

## 🎴 Mod Integrations

### **CardSleeves**
* **Battery Sleeve**: Provides battery accumulation mechanics.
* **Deck + Sleeve Combo**: If you play with the **Battery Deck** and the **Battery Sleeve** together:
  * Charges **2X faster** (doubles stored surplus).
  * Discharges **2X slower** (consumes only half the needed reserve).
  * Has **Infinite Battery Capacity**.

### **JokerDisplay**
* Fully integrated reminder texts, active status, probability counters, and target Joker displays for all Jokers in the mod.

---

## 🌐 Localization

* **English** (default)
* **Português (Brasil)**

---

## 📦 Requirements

* [Steamodded](https://github.com/Steamodded/smods) (v1.0.0+)
* [Lovely](https://github.com/ethangreen-dev/lovely-injector)

---

## 🛠️ Installation

1. Download or clone this repository into your Balatro Mods folder:
   * **Windows**: `%AppData%/Balatro/Mods/`
   * **Linux**: `~/.local/share/Balatro/Mods/`
   * **macOS**: `~/Library/Application Support/Balatro/Mods/`
2. Ensure Steamodded is installed and loaded.
3. Launch Balatro and enjoy!

---

## 👤 Author

* **Wayron**
