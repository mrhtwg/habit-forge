package game

import (
	"testing"
	"time"
)

func TestExpForLevel(t *testing.T) {
	cases := []struct {
		level, want int
	}{
		{1, 100},
		{2, 160}, // 100 + 50 + 10
		{3, 240}, // 100 + 100 + 40
	}
	for _, tc := range cases {
		if got := ExpForLevel(tc.level); got != tc.want {
			t.Errorf("ExpForLevel(%d)=%d want %d", tc.level, got, tc.want)
		}
	}
}

func TestGainExp(t *testing.T) {
	c := Character{Level: 1, CurrentExp: 0, CurrentHp: 80, BaseStats: Stats{}}
	c2, newLevel := GainExp(c, 100, nil)
	if newLevel != 2 {
		t.Fatalf("expected level 2, got %d", newLevel)
	}
	if c2.Level != 2 {
		t.Fatalf("character level=%d want 2", c2.Level)
	}
	if c2.CurrentExp != 0 {
		t.Fatalf("currentExp=%d want 0", c2.CurrentExp)
	}
	if c2.AvailableStatPoints != 1 {
		t.Fatalf("stat points=%d want 1", c2.AvailableStatPoints)
	}
	if c2.CurrentHp != 100 { // 80+20 clamped to maxHp 100
		t.Fatalf("hp=%d want 100", c2.CurrentHp)
	}
	c3, nl := GainExp(c2, 50, nil)
	if nl != -1 {
		t.Fatalf("expected -1, got %d", nl)
	}
	if c3.CurrentExp != 50 {
		t.Fatalf("exp=%d want 50", c3.CurrentExp)
	}
}

func TestTakeDamage(t *testing.T) {
	now := time.Now()
	c := Character{Level: 1, CurrentHp: 50, BaseStats: Stats{Defense: 5}}
	c2 := TakeDamage(c, 10, nil, now)
	if c2.CurrentHp != 45 {
		t.Fatalf("hp=%d want 45", c2.CurrentHp)
	}
	c3 := TakeDamage(Character{CurrentHp: 5, BaseStats: Stats{Defense: 100}}, 10, nil, now)
	if c3.CurrentHp != 4 {
		t.Fatalf("min damage hp=%d want 4", c3.CurrentHp)
	}
	dead := TakeDamage(Character{CurrentHp: 1, BaseStats: Stats{}}, 10, nil, now)
	if !dead.IsDead || dead.CurrentHp != 0 {
		t.Fatalf("expected dead at 0 hp, got dead=%v hp=%d", dead.IsDead, dead.CurrentHp)
	}
	if dead.DeathRecoveryUntil == 0 {
		t.Fatal("expected death recovery timestamp")
	}
}
