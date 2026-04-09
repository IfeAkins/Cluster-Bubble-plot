i# ============================================================
# Cluster Timeline Bubble Plot
# ============================================================
# Description: Visualises weekly cluster dynamics across
#              Enterobacteriaceae sequence types (STs) using
#              Illumina-based clustering data. Bubble size
#              represents the number of unique patients per
#              ST per week.
#
# Input:  figure1_metadata_160326.csv
# Output: TAPIR_cluster_bubble_plot.svg
#         TAPIR_cluster_bubble_plot.png
#
# Author: Ife
# ============================================================

library(tidyverse)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------
figure1 <- read.csv("figure1_metadata_160326.csv", sep = ",", header = TRUE)

# ------------------------------------------------------------
# 2. Standardise column names
# ------------------------------------------------------------
colnames(figure1) <- c("identifier", "week", "ID", "source",
                       "Cluster", "Cluster_ID", "ST", "species")

# ------------------------------------------------------------
# 3. Remove singletons (clusters with only one isolate)
# ------------------------------------------------------------
figure1_filtered <- figure1 %>%
  filter(Cluster_ID != "singleton")

# ------------------------------------------------------------
# 4. Create species_ST label (e.g., "Eco_ST131")
# ------------------------------------------------------------
figure1_filtered <- figure1_filtered %>%
  mutate(species_ST = paste(species, ST, sep = "_"))

# ------------------------------------------------------------
# 5. Map species abbreviations to full names for legend
# ------------------------------------------------------------
figure1_filtered <- figure1_filtered %>%
  mutate(species_full = recode(species,
                               "Ecl" = "E. cloacae",
                               "Eco" = "E. coli",
                               "Kox" = "K. oxytoca",
                               "Kpn" = "K. pneumoniae"
  ))

# ------------------------------------------------------------
# 6. Count unique patients per week and species_ST combination
# ------------------------------------------------------------
figure1_count <- figure1_filtered %>%
  group_by(week, species_ST, species_full) %>%
  summarise(n_patients = n_distinct(ID), .groups = "drop")

# ------------------------------------------------------------
# 7. Plot
# ------------------------------------------------------------
p <- ggplot(figure1_count,
            aes(x = week, y = species_ST,
                size = n_patients, fill = species_full)) +
  
  geom_point(alpha = 0.7, shape = 21, colour = "black") +
  
  # Bubble size scale
  scale_size_continuous(
    range  = c(2, 12),
    breaks = c(2, 4, 6, 8, 10, 12),
    limits = c(1, max(figure1_count$n_patients))
  ) +
  
  # Colour palette
  scale_fill_brewer(palette = "Set2") +
  
  # X-axis: every 2 weeks from 1 to 56
  scale_x_continuous(
    breaks = seq(1, 56, 2),
    limits = c(1, 56)
  ) +
  
  # Legend formatting
  guides(
    fill = guide_legend(override.aes = list(size = 5)),
    size = guide_legend(override.aes = list(fill = "transparent",
                                            colour = "black"))
  ) +
  
  # Labels
  labs(
    title = "Cluster timeline using Illumina data",
    x     = "Week",
    y     = "Cluster ID",
    fill  = "Species",
    size  = "No. of patients"
  ) +
  
  # Theme
  theme_minimal() +
  theme(
    axis.text.y    = element_text(face = "bold"),
    axis.text.x    = element_text(face = "bold", angle = 45, hjust = 1),
    axis.title.y   = element_text(face = "bold"),
    axis.title.x   = element_text(face = "bold"),
    plot.title     = element_text(face = "bold", hjust = 0.5),
    legend.position = "right",
    panel.grid.major = element_line(colour = "grey90")
  )
p
# ------------------------------------------------------------
# 8. Save outputs
# ------------------------------------------------------------
ggsave("TAPIR_cluster_bubble_plot.svg", plot = p, width = 12, height = 8)
ggsave("TAPIR_cluster_bubble_plot.png", plot = p, width = 12, height = 8, dpi = 300)

message("Done! Plots saved as SVG and PNG.")

