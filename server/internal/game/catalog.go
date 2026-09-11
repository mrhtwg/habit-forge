package game

import (
	"embed"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
)

//go:embed catalog.yml
var embeddedCatalog embed.FS

// Catalog holds shop items and achievement definitions loaded from YAML.
type Catalog struct {
	Items        []CatalogItem
	Achievements []AchievementDef
	bonus        map[string]Stats
	gemCurrency  map[string]bool
}

// CatalogItem is one shop catalog entry.
type CatalogItem struct {
	ID          string
	Name        string
	Description string
	Price       int64
	Slot        string // weapon | helmet | armor | accessory
	Rarity      string // common | rare | epic | legendary
	Currency    string // gold | gems
	Icon        string
	Stats       Stats
	Category    string // equipment | appearance
}

type catalogYAML struct {
	AchievementDefs []struct {
		ID            string `yaml:"id"`
		Title         string `yaml:"title"`
		Description   string `yaml:"description"`
		ConditionType string `yaml:"condition_type"`
		Threshold     int    `yaml:"threshold"`
		GemReward     int    `yaml:"gem_reward"`
	} `yaml:"achievement_defs"`
	Equipment []struct {
		ID          string         `yaml:"id"`
		Slot        string         `yaml:"slot"`
		Name        string         `yaml:"name"`
		Description string         `yaml:"description"`
		Price       int64          `yaml:"price"`
		Rarity      string         `yaml:"rarity"`
		Currency    string         `yaml:"currency"`
		Icon        string         `yaml:"icon"`
		Stats       map[string]int `yaml:"stats"`
	} `yaml:"equipment"`
	Skins []struct {
		ID          string `yaml:"id"`
		Name        string `yaml:"name"`
		Description string `yaml:"description"`
		Price       int64  `yaml:"price"`
		Rarity      string `yaml:"rarity"`
		Currency    string `yaml:"currency"`
		Icon        string `yaml:"icon"`
	} `yaml:"skins"`
	Accessories []struct {
		ID          string         `yaml:"id"`
		Slot        string         `yaml:"slot"`
		Name        string         `yaml:"name"`
		Description string         `yaml:"description"`
		Price       int64          `yaml:"price"`
		Rarity      string         `yaml:"rarity"`
		Currency    string         `yaml:"currency"`
		Icon        string         `yaml:"icon"`
		Stats       map[string]int `yaml:"stats"`
	} `yaml:"accessories"`
}

// LoadCatalog tries configs/catalog.yml, ../app/assets/config/config.yml, then embed.
func LoadCatalog() (*Catalog, error) {
	candidates := []string{
		"configs/catalog.yml",
		filepath.Join("configs", "catalog.yml"),
		filepath.Join("..", "app", "assets", "config", "config.yml"),
		filepath.Join("internal", "game", "catalog.yml"),
	}
	for _, p := range candidates {
		data, err := os.ReadFile(p)
		if err != nil {
			continue
		}
		return ParseCatalog(data)
	}
	data, err := embeddedCatalog.ReadFile("catalog.yml")
	if err != nil {
		return nil, fmt.Errorf("catalog: no file found and embed failed: %w", err)
	}
	return ParseCatalog(data)
}

// ParseCatalog parses YAML catalog bytes.
func ParseCatalog(data []byte) (*Catalog, error) {
	var raw catalogYAML
	if err := yaml.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("catalog yaml: %w", err)
	}
	c := &Catalog{
		bonus:       make(map[string]Stats),
		gemCurrency: make(map[string]bool),
	}
	for _, a := range raw.AchievementDefs {
		c.Achievements = append(c.Achievements, AchievementDef{
			ID:            a.ID,
			Title:         a.Title,
			Description:   a.Description,
			ConditionType: a.ConditionType,
			Threshold:     a.Threshold,
			GemReward:     a.GemReward,
		})
	}
	addEquip := func(id, slot, name, desc, rarity, currency, icon string, price int64, stats map[string]int, category string) {
		st := parseStats(stats)
		item := CatalogItem{
			ID:          id,
			Name:        name,
			Description: desc,
			Price:       price,
			Slot:        slot,
			Rarity:      rarity,
			Currency:    normalizeCurrency(currency),
			Icon:        icon,
			Stats:       st,
			Category:    category,
		}
		c.Items = append(c.Items, item)
		if category == "equipment" {
			c.bonus[id] = st
		}
		if item.Currency == "gems" {
			c.gemCurrency[id] = true
		}
	}
	for _, e := range raw.Equipment {
		addEquip(e.ID, e.Slot, e.Name, e.Description, e.Rarity, e.Currency, e.Icon, e.Price, e.Stats, "equipment")
	}
	for _, e := range raw.Accessories {
		slot := e.Slot
		if slot == "" {
			slot = "accessory"
		}
		addEquip(e.ID, slot, e.Name, e.Description, e.Rarity, e.Currency, e.Icon, e.Price, e.Stats, "equipment")
	}
	for _, s := range raw.Skins {
		cur := s.Currency
		if cur == "" {
			cur = "gems"
		}
		addEquip(s.ID, "", s.Name, s.Description, s.Rarity, cur, s.Icon, s.Price, nil, "appearance")
	}
	return c, nil
}

func parseStats(m map[string]int) Stats {
	if m == nil {
		return Stats{}
	}
	return Stats{
		Strength:     m["str"],
		Intelligence: m["int"],
		Agility:      m["agi"],
		Defense:      m["def"],
		Vitality:     m["vit"],
		Luck:         m["luk"],
	}
}

func normalizeCurrency(c string) string {
	if strings.EqualFold(c, "gems") || strings.EqualFold(c, "gem") {
		return "gems"
	}
	return "gold"
}

// BonusOf returns equipment bonus stats for an item id.
func (c *Catalog) BonusOf(itemID string) Stats {
	if c == nil {
		return Stats{}
	}
	return c.bonus[itemID]
}

// IsGems reports whether the item is paid with gems.
func (c *Catalog) IsGems(itemID string) bool {
	if c == nil {
		return false
	}
	return c.gemCurrency[itemID]
}

// ItemByID finds a catalog item.
func (c *Catalog) ItemByID(id string) (CatalogItem, bool) {
	if c == nil {
		return CatalogItem{}, false
	}
	for _, it := range c.Items {
		if it.ID == id {
			return it, true
		}
	}
	return CatalogItem{}, false
}

// BonusLookup returns a BonusLookup bound to this catalog.
func (c *Catalog) BonusLookup() BonusLookup {
	return c.BonusOf
}
