import sys
import os
from langdetect import detect, LangDetectException

# Add the project root to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.write.writer import WritingCorrector
from app.talk.talker import TalkingPartner

def select_languages():
    """Prompts the user to select native and target languages."""
    print("\nFirst, let's set up your languages.")
    lang_map = {'1': 'en', '2': 'tr', '3': 'es'}
    
    # Select Native Language
    print("\nSelect your NATIVE language:")
    print("1. English")
    print("2. Turkish")
    print("3. Spanish")
    while True:
        native_choice = input("Enter your choice (1, 2, or 3): ")
        if native_choice in lang_map:
            native_lang = lang_map[native_choice]
            break
        else:
            print("Invalid choice. Please try again.")

    # Select Target Language
    print("\nNow, select the language you want to LEARN:")
    print("1. English")
    print("2. Turkish")
    print("3. Spanish")
    while True:
        target_choice = input("Enter your choice (1, 2, or 3): ")
        if target_choice in lang_map:
            if lang_map[target_choice] == native_lang:
                print("Target language cannot be the same as your native language. Please choose a different one.")
                continue
            target_lang = lang_map[target_choice]
            break
        else:
            print("Invalid choice. Please try again.")
            
    return native_lang, target_lang

def main():
    """
    Main function to run the Talkive application.
    """
    print("Welcome to Talkive! Your personal language learning assistant.")
    
    native_language, target_language = select_languages()
    print(f"\nSetup complete! Native: {native_language.upper()}, Learning: {target_language.upper()}")

    corrector = None
    talker = None

    while True:
        print("\nChoose a mode:")
        print(f"1. Write Mode (Chat & Correct)")
        print(f"2. Talk Mode (Chat & Correct)")
        print("3. Change Languages")
        print("4. Exit")

        choice = input("Enter your choice (1, 2, 3, or 4): ")

        if choice == '1' or choice == '2': # Both modes now have the same functionality
            # Initialize both models
            if not corrector:
                corrector = WritingCorrector(language=target_language)
            if not talker:
                talker = TalkingPartner(language=target_language)

            if not corrector.correction_pipeline or not talker.talk_pipeline:
                print("Could not start mode due to model initialization failure.")
                continue

            mode_name = "Write" if choice == '1' else "Talk"
            print(f"\nEntering {mode_name} Mode. You'll get corrections and conversational replies.")
            print("Type 'exit' to return to the main menu.")

            while True:
                user_input = input("> You: ")
                if user_input.lower() == 'exit':
                    break
                
                try:
                    detected_lang = detect(user_input)
                    if detected_lang == native_language:
                        print(f"(Tip: It looks like you wrote in {native_language.upper()}. Try writing in {target_language.upper()}.)")
                        continue
                except LangDetectException:
                    pass

                # Core combined functionality
                corrected_text = corrector.correct_text(user_input)
                response = talker.get_response(user_input)
                
                print(f"  \\_Correction: {corrected_text}")
                print(f"  \\_AI: {response}")

        elif choice == '3':
            native_language, target_language = select_languages()
            print(f"\nLanguages updated! Native: {native_language.upper()}, Learning: {target_language.upper()}")
            corrector = None
            talker = None

        elif choice == '4':
            print("Goodbye!")
            break

        else:
            print("Invalid choice. Please enter 1, 2, 3, or 4.")

if __name__ == "__main__":
    main()
