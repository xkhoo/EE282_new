library(ggplot2)

short <- read.delim("output/reports/homework4/shorter_100kb_gc.tsv", sep = "\t", header = TRUE)
long  <- read.delim("output/reports/homework4/longer_100kb_gc.tsv", sep = "\t", header = TRUE)

# shorter than 100 kb length histogram
p1 <- ggplot(short, aes(x = length)) +
  geom_histogram(bins = 40) +
  scale_x_log10() +
  labs(
    title = "Sequence length distribution (<=100 kb)",
    x = "Sequence length (log10 scale)",
    y = "Count"
  ) +
  theme_bw(base_size = 16)

ggsave("output/figures/homework4/shorter_100kb_length_hist.png", p1, width = 7, height = 5)

# shorter than 100 kb GC histogram
p2 <- ggplot(short, aes(x = gc)) +
  geom_histogram(bins = 30) +
  labs(
    title = "GC distribution (<=100 kb)",
    x = "GC",
    y = "Count"
  ) +
  theme_bw(base_size = 16)

ggsave("output/figures/homework4/shorter_100kb_gc_hist.png", p2, width = 7, height = 5)

# longer than 100 kb length histogram
p3 <- ggplot(long, aes(x = length)) +
  geom_histogram(bins = 30) +
  scale_x_log10() +
  labs(
    title = "Sequence length distribution (>100 kb)",
    x = "Sequence length (log10 scale)",
    y = "Count"
  )+
  theme_bw(base_size = 16)

ggsave("output/figures/homework4/longer_100kb_length_hist.png", p3, width = 7, height = 5)

# longer than 100 kb GC histogram
p4 <- ggplot(long, aes(x = gc)) +
  geom_histogram(bins = 30) +
  labs(
    title = "GC distribution (>100 kb)",
    x = "GC",
    y = "Count"
  ) +
  theme_bw(base_size = 16)

ggsave("output/figures/homework4/longer_100kb_gc_hist.png", p4, width = 7, height = 5)
