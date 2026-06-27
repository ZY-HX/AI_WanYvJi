package com.english.dto;

import lombok.Data;

@Data
public class WordLookupResponse {

    private String english;

    private String chinese;

    private String phonetic;
}
