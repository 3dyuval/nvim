<!--
drill: repeat patterns — 2026-10-18
subject: f/t/F/T find-repeat (; ,) vs change-repeat (.)
augment: cr"NEW keeps the quotes (t=around would delete them in this layout)
-->
<script setup lang="ts">
import { ref, computed } from 'vue'

// Section 1: jump to each opening brace left-to-right, then walk back
const a = { x: { y: { z: 1 } } }



// Section 2: stop just before each comma, advancing one at a time
const nums = [10, 20, 30, 40, 50]



// Section 3: delete the name up to each =, repeating the same edit down the lines
const alpha = ref(1)
const beta  = ref(2)
const gamma = ref(3)



// Section 4: change each animal name to foo, repeating the change word by word
const dog = 1
const cat = 2
const owl = 3



// Section 5: replace the text inside each string with NEW, keeping the quotes
const labels = ["one", "two", "three"]
</script>
