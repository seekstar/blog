---
title: RocksDB代码分析——Compaction的输入文件的选择
date: 2022-06-02 12:17:40
tags: RocksDB
---

这里主要分析`LevelCompactionBuilder::PickCompaction`是如何选择输入文件的。

>`SetupInitialFiles();`找一个需要compact到下层的SST file。只会在score >= 1的level里找。score的计算见`VersionStorageInfo::ComputeCompactionScore`（{% post_link Storage/'RocksDB代码分析——Compaction流程' %}）。
>`LevelCompactionBuilder::SetupOtherL0FilesIfNeeded`
>
>>`CompactionPicker::GetOverlappingL0Files`
>>
>>>`CompactionPicker::GetRange`，拿到这个file的smallest和largest
>>>`VersionStorageInfo::GetOverlappingInputs`，拿到L0中所有跟[smallest, largest] overlap的file。
>>>然后再`CompactionPicker::GetRange`更新一下range，检查一下冲突。然后不再继续get overlapping L0 files了。
>
>`LevelCompactionBuilder::SetupOtherInputsIfNeeded`
>
>>`CompactionPicker::SetupOtherInputs`
>>
>>>`VersionStorageInfo::GetOverlappingInputs`，把所有跟`start_level_inputs`相交的下一层的sst file都加入到`output_level_inputs_`里。
>>>`CompactionPicker::ExpandInputsToCleanCut`，expand `output_level_inputs_` 直到clean cut。
>>>扩大`start_level_inputs`，只要不会扩大`output_level_inputs_`。细节：首先尝试把所有跟`output_level_inputs`相交的start level的sst file都放入input，然后看会不会导致`output_level_inputs_`变大，如果会的话，就再尝试所有在`output_level_inputs_`范围内的所有start level的sst file都放入input。
