---
title: CV
date: 2026-08-25 00:00:00
---

<style>
.cv-row { display: flex; justify-content: space-between; gap: 20px; }
.cv-row time { flex-shrink: 0; }
</style>

<div>
  <div><strong>Jiansheng Qiu</strong></div>
  <div>Institute for Interdisciplinary Information Sciences, Tsinghua University</div>
  <div>Phone: <a href="tel:+8618126126249">(+86) 18126126249</a></div>
  <div>Email: <a href="mailto:jianshengqiu.cs@gmail.com">jianshengqiu.cs@gmail.com</a></div>
  <div>FIT Building, Tsinghua University, Beijing, China 100084</div>
</div>

## Research Interests

My research interest is in storage systems. My recent research focus is on LSM-trees.

## Education

<div class="cv-row"><strong>Tsinghua University</strong><time>Sep 2021 – Present</time></div>
<div class="cv-row"><span>Computer Science, PhD Student</span><span>Beijing, China</span></div>

Advisor: Huanchen Zhang

<div class="cv-row"><strong>Harbin Institute of Technology, Shenzhen</strong><time>Aug 2017 – Jul 2021</time></div>
<div class="cv-row"><span>Computer Science, Bachelor</span><span>Shenzhen, China</span></div>

Advisor: Wen Xia

## Honors & Awards

<div class="cv-row"><span>National Scholarship</span><time>Dec 14, 2020</time></div>
<div class="cv-row"><span>Full marks in the Top Level of Programming Ability Test (PAT)</span><time>Sep 5, 2020</time></div>
<div class="cv-row"><span>Silver Medal of ICPC Asia Nanchang Regional Contest</span><time>Nov 10, 2019</time></div>
<div class="cv-row"><span>Silver Medal of China Collegiate Programming Contest (CCPC), Harbin Site</span><time>Oct 2019</time></div>

## Project Experience

<div class="cv-row"><strong>(USENIX ATC '25) HotRAP <a href="#atc2025hotrap">[1]</a></strong><time>2022 – 2025</time></div>

HotRAP is my first PhD work supervised by Prof. Huanchen Zhang. HotRAP is a key-value store based on RocksDB that can timely promote hot records from slow to fast storage and retain them in fast storage while they remain hot. It has two primary contributions:

1. Previous approaches track hotness of records in memory, which can consume much memory if records are small. HotRAP uses an on-disk data structure to perform record-level hotness tracking while maintaining modest memory consumption.
2. Previous systems promote hot data only through compactions, which is insufficient under read-heavy workloads. HotRAP batches hot records and promotes them to the fast storage by flushing them as an SSTable, enabling efficient performance even under read-heavy workloads.

<div class="cv-row"><strong>(USENIX ATC '23) Light-Dedup <a href="#atc2023lightdedup">[2]</a></strong><time>2020 – 2023</time></div>

Light-Dedup is my undergraduate work advised by Prof. Wen Xia. Light-Dedup is an inline deduplication framework for Non-Volatile Memory (NVM) file systems. It has two main contributions:

1. Light-Dedup observes that the CPU prefetcher is too conservative for NVM and optimizes content comparison by speculatively prefetching in-NVM data blocks.
2. Light-Dedup organizes the deduplication metadata at region granularity to reduce metadata I/O amplification when the file system is aged.

## Publications

<p id="atc2025hotrap">[1] <strong>Jiansheng Qiu</strong>, Fangzhou Yuan, Mingyu Gao, and Huanchen Zhang. HotRAP: Hot Record Retention and Promotion for LSM-trees with Tiered Storage. In <em>2025 USENIX Annual Technical Conference (USENIX ATC 25)</em>, 2025.</p>

<p id="atc2023lightdedup">[2] <strong>Jiansheng Qiu</strong>, Yanqi Pan, Wen Xia, Xiaojia Huang, Wenjun Wu, Xiangyu Zou, Shiyi Li, and Yu Hua. Light-Dedup: A Light-weight Inline Deduplication Framework for Non-Volatile Memory File Systems. In <em>2023 USENIX Annual Technical Conference (USENIX ATC 23)</em>, 2023.</p>
